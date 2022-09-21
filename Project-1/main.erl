-module(main).
-export([main/1]).

checkHash(RandomNum, NumZeros) ->
    HashInput = string:concat("mahajanh;",integer_to_list(RandomNum)),
    <<Temp:256>> = crypto:hash(sha256, HashInput),
    HashOutput = io_lib:format("~64.16.0b", [Temp]),
    % io:format("~s\n", [HashOutput]),
    case (string:substr(HashOutput, 1, NumZeros)==string:left("",NumZeros, $0)) of
        true -> io:format("~s ~s\n",[HashInput, HashOutput]);
        false -> ""
    end.

startWork() ->
    ok.

startWork(StartNum, EndNum, NumZeros) ->
    checkHash(StartNum, NumZeros),
    case StartNum < EndNum of 
        true -> startWork(StartNum + 1, EndNum, NumZeros);
        false -> startWork()
    end.

main(NumZeros) ->
    io:format("Zeros Required : ~p\n",[NumZeros]),
    RandomNum = 10000000+rand:uniform(10000000),
    startWork(RandomNum, RandomNum + 10000000, NumZeros).

