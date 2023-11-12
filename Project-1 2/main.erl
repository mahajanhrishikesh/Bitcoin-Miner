-module(main).
-export([startWork/1, startWork/4]).

checkHash(RandomNum, Master, NumZeros) ->
    % io:format("There"),
    HashInput = string:concat("mahajanh;",integer_to_list(RandomNum)),
    <<Temp:256>> = crypto:hash(sha256, HashInput),
    HashOutput = io_lib:format("~64.16.0b", [Temp]),    
    case (string:substr(HashOutput, 1, NumZeros)==string:left("",NumZeros, $0)) of
        true -> Master ! {self(), {HashInput, HashOutput, print}};%io:format("~s ~s\n",[HashInput, HashOutput]);
        false -> done
    end.

startWork(Master, StartNum, EndNum, NumZeros) ->
    % io:format("Here"),
    checkHash(StartNum, Master, NumZeros),
    case StartNum < EndNum of 
        true -> startWork(Master, StartNum + 1, EndNum, NumZeros);
        false -> startWork(Master)
    end.

startWork(Master) ->
    Master ! {self(), {givemework}},
    receive
        {Master, {StartNum, EndNum, K}} ->
            startWork(Master, StartNum, EndNum, K)
    end.

% main(NumZeros) ->
%     io:format("Zeros Required : ~p\n",[NumZeros]),
%     RandomNum = 10000000+rand:uniform(10000000),
%     spawn(main, startWork,[RandomNum, RandomNum + 10000000, NumZeros]),
%     spawn(main, startWork,[RandomNum+10000000, RandomNum + 20000000, NumZeros]),
%     spawn(main, startWork,[RandomNum+20000000, RandomNum + 30000000, NumZeros]).
