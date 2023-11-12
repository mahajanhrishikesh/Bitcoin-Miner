-module(mainGossip).

-export([startWork/3]).

startWork(SID, Actors, HeardCount) ->
    receive 
        {actors, NewActors} ->
            startWork(SID, NewActors, HeardCount);
        {showActors} ->
            io:format("~p",[Actors]),
            startWork(SID, Actors, HeardCount);
        {updateActors, NewActors} ->
            startWork(SID, NewActors, HeardCount);
        {addActor, Actor} ->
            startWork(SID, lists:append([Actors, [Actor]]), HeardCount);
        {rumour, Rumour} ->
            NewHeardCount = HeardCount + 1,
            case NewHeardCount < 10 of
                true -> 
                    SendTo1 = lists:nth(rand:uniform(length(Actors)), Actors),
                    SendTo1 ! {rumour, Rumour},
                    SendTo2 = lists:nth(rand:uniform(length(Actors)), Actors),
                    SendTo2 ! {rumour, Rumour},
                    startWork(SID,Actors,NewHeardCount);
                false -> 
                    SID ! {rumourHeard, self()}
            end
    end.
    