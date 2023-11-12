-module(mainGossipWFail).

-export([startWork/4]).

startWork(SID, Actors, HeardCount, Fail) ->
    receive 
        {actors, NewActors} ->
            startWork(SID, NewActors, HeardCount, Fail);
        {showActors} ->
            io:format("~p",[Actors]),
            startWork(SID, Actors, HeardCount, Fail);
        {updateActors, NewActors} ->
            startWork(SID, NewActors, HeardCount, Fail);
        {addActor, Actor} ->
            startWork(SID, lists:append([Actors, [Actor]]), HeardCount, Fail);
        {rumour, Rumour} ->
            NewHeardCount = HeardCount + 1,
            case NewHeardCount < 10 of
                true -> 
                    SendTo1 = lists:nth(rand:uniform(length(Actors)), Actors),
                    SendTo1 ! {rumour, Rumour},
                    SendTo2 = lists:nth(rand:uniform(length(Actors)), Actors),
                    SendTo2 ! {rumour, Rumour},
                    startWork(SID,Actors,NewHeardCount, Fail);
                false -> 
                    SID ! {rumourHeard, self()}
            end
    end.
    