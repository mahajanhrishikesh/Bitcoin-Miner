-module(master).

-export([start/2, loop/2]).

start(K, NI) -> 
    io:format("Runtime: ~p ~n",[statistics(runtime)]),
    io:format("WallClock: ~p ~n",[statistics(wall_clock)]),
    io:format("Zeros Required : ~p\n",[K]),
    RandomNum = 10000000+rand:uniform(10000000),
    io:format("~p\n",[RandomNum]),
    SID = spawn(master, loop, [K, RandomNum]),
    io:format("~p~n",[SID]),
    register(msid, SID),
    makeInitialActors(NI, K, SID),
    {extAddr, 'ys@10.20.26.19'} ! {rise, NI, K, 'hm@10.20.26.48'}.

makeInitialActors(0) -> done.

makeInitialActors(NI, K, SID) ->
    spawn(main, startWork, [SID]),
    case NI > 1 of
        true -> makeInitialActors(NI-1, K, SID);
        false -> makeInitialActors(0)
    end.

loop(K, RandomNum) ->
    receive
        {Actor, {givemework}}->
            %io:format("Runtime: ~p ~n",[statistics(runtime)]),
            %io:format("WallClock: ~p ~n",[statistics(wall_clock)]),
            StartNum = RandomNum,
            EndNum = RandomNum + 10000000,
            Actor ! {self(), {StartNum, EndNum, K}},
            loop(K, RandomNum+10000000);
        {Actor, {HashInput, HashOutput, print}} ->
            io:format("~p -> ~s ~s\n",[Actor, HashInput, HashOutput]),
            loop(K, RandomNum);
        {getTime} ->
            io:format("Runtime: ~p ~n",[statistics(runtime)]),
            io:format("WallClock: ~p ~n",[statistics(wall_clock)]),
            loop(K, RandomNum)
    end.