-module(extmain).
-export([startWork/1, startWork/5]).

checkHash(RandomNum, Master, MasterNode, NumZeros) ->
    % io:format("There"),
    HashInput = string:concat("mahajanh;",integer_to_list(RandomNum)),
    <<Temp:256>> = crypto:hash(sha256, HashInput),
    HashOutput = io_lib:format("~64.16.0b", [Temp]),    
    case (string:substr(HashOutput, 1, NumZeros)==string:left("",NumZeros, $0)) of
        true -> {msid, MasterNode} ! {self(), {HashInput, HashOutput, print}};%io:format("~s ~s\n",[HashInput, HashOutput]);
        false -> done
    end.

startWork(Master, MasterNode, StartNum, EndNum, NumZeros) ->
    % io:format("Here"),
    checkHash(StartNum, Master, MasterNode, NumZeros),
    case StartNum < EndNum of 
        true -> startWork(Master, MasterNode, StartNum + 1, EndNum, NumZeros);
        false -> startWork(MasterNode)
    end.

startWork(MasterNode) ->
    {msid, MasterNode} ! {self(), {givemework}},
    receive
        {Master, {StartNum, EndNum, K}} ->
            startWork(Master, MasterNode, StartNum, EndNum, K)
    end.