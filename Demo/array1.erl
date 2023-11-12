-module(array1).

-export([make/0, minion/1]).


makeMinions(N,L1,CPID)->
    PID = spawn(array1, minion, [[]]),
    L2=L1++[PID],
    case N > 0 of
        true -> PID ! {banana},
        makeMinions(N-1, L2, CPID);
        false-> io:format("Sending out actors now... ~p", [L2]),
        CPID ! {allActorsMade, L2}
    end.

makeNeighbors(Idx, Len, NeighList) ->
    case Idx =< Len of
        true ->
            CurrNode = lists:nth(Idx, NeighList),
            NeighborsCurrNode = [I || I <- NeighList, I/=CurrNode],
            CurrNode ! {neighbors, NeighborsCurrNode},
            makeNeighbors(Idx+1, Len, NeighList);
        false ->
            done
    end.

make() ->
    receive 
        {start}->
            makeMinions(10, [], self()),
            make();
        {allActorsMade, L2} ->
            io:format("Sending out actors now..."),
            makeNeighbors(1, length(L2), L2),
            make()
    end.

minion(NeighList) ->
    receive
        {banana}->
            io:fwrite("banana\n"),
            io:format("~p",[NeighList]),
            minion(NeighList);
            
        {neighbors, NewNeighList} ->
            self() ! {banana},
            minion(NewNeighList)
    end.

