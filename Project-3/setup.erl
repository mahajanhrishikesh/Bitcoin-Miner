-module(setup).

-export([build/2, process/6]).

build(NActors, NQueries) ->
    SID = spawn(setup, process, [NActors, NQueries, [], [], 0, 0]),
    makeInitialActors(NActors, NQueries, SID, []).

makeInitialActors(NActors, NQueries, SID, Actors) ->
    CurrActor = spawn(node, start, [SID, NActors, NQueries, {}, #{}, -1, {}]),
    case NActors > 0 of
        true -> 
            NewActors = lists:append([Actors, [CurrActor]]),
            makeInitialActors(NActors-1, NQueries, SID, NewActors);
        false -> 
            SID ! {allActorsMade, Actors}
    end.

sortnsend(MID, Actors) ->
    SHAHashOP = [{crypto:hash(sha, pid_to_list(I)), I} || I <- Actors],
    SHAHashOPProc = [{list_to_integer(io_lib:format("~64.16.0b",[binary:decode_unsigned(element(1, I))]), 16), element(2,I)} || I <- SHAHashOP],
    Hash2PID = lists:sort(SHAHashOPProc),
    PID2Hash = [{element(2, I), element(1, I)}|| I <- Hash2PID],
    [I!{getFingerTable, Hash2PID} || I <- Actors],
    io:format("~p ~n ~p ~n",[Hash2PID, PID2Hash]),
    [I!{startRequests} || I<-Actors].
    


process(NActors, NQueries, Actors, HashedActors, Sum, Ctr) ->
    receive
        {allActorsMade, NewActors} ->
            sortnsend(self(), NewActors),
            process(NActors, NQueries, NewActors, HashedActors, Sum, Ctr);
        {allActorsHashed, NewHashedActors} ->
            process(NActors, NQueries, Actors, NewHashedActors, Sum, Ctr);
        {test} ->
            io:format("OUCH!"),
            process(NActors, NQueries, Actors, HashedActors, Sum, Ctr);
        {found, Hops} ->
            NewSum = Sum + Hops,
            NewCtr = Ctr + 1,
            io:format("Found key in ~p hops and ~p / ~p = ~p average.~n",[Hops, NewSum, NewCtr, NewSum/NewCtr]),
            process(NActors, NQueries, Actors, HashedActors, NewSum, NewCtr)
    end.
