-module(mainPushSum).

-export([startWork/6]).

startWork(SID, Actors, DiffCount, S, W, OldEstimate) ->
    receive 
        {actors, NewActors} ->
            startWork(SID, NewActors, DiffCount, S, W, OldEstimate);
        {showActors} ->
            io:format("~p",[Actors]),
            startWork(SID, Actors, DiffCount, S, W, OldEstimate);
        {updateActors, NewActors} ->
            startWork(SID, NewActors, DiffCount, S, W, OldEstimate);
        {addActor, Actor} ->
            startWork(SID, lists:append([Actors, [Actor]]), DiffCount, S, W, OldEstimate);
        {showCurrEstimate} ->
            io:format("~p ~p \n",[OldEstimate, DiffCount]),
            startWork(SID, Actors, DiffCount, S, W, OldEstimate);
        {starter} ->
            SendTo1 = lists:nth(rand:uniform(length(Actors)), Actors),
            SendTo1 ! {estimate, S/2, W/2},
            startWork(SID, Actors, DiffCount, S/2, W/2, OldEstimate);
        {estimate, NewS, NewW} ->
            NewSS = S + NewS,
            NewWW = W + NewW,
            NewEstimate = NewSS / NewWW,
            if 
                abs(NewEstimate - OldEstimate) =< 0.00000000001 ->
                NewDiffCount = DiffCount + 1,
                case NewDiffCount < 3 of
                    true -> 
                        SendTo1 = lists:nth(rand:uniform(length(Actors)), Actors),
                        %io:format("~p SPECIAL ~p - ~p = ~p\n", [NewDiffCount,OldEstimate, NewEstimate, abs(NewEstimate-OldEstimate)]),
                        SendTo1 ! {estimate, NewSS/2, NewWW/2},
                        % SendTo2 = lists:nth(rand:uniform(length(Actors)), Actors),
                        % %io:format("SPECIAL ~p - ~p = ~p\n", [OldEstimate, NewEstimate, abs(NewEstimate-OldEstimate)]),
                        % SendTo2 ! {estimate, NewSS/2, NewWW/2},
                        startWork(SID, Actors, NewDiffCount, NewSS/2, NewWW/2, NewEstimate);
                    false -> 
                        SID ! {estimateHeard, self(), NewEstimate}
                end;
                true ->
                    SendTo1 = lists:nth(rand:uniform(length(Actors)), Actors),
                    %io:format("~p - ~p = ~p\n", [OldEstimate, NewEstimate, abs(NewEstimate-OldEstimate)]),
                    SendTo1 ! {estimate, NewSS/2, NewWW/2},
                    % SendTo2 = lists:nth(rand:uniform(length(Actors)), Actors),
                    % %io:format("SPECIAL ~p - ~p = ~p\n", [OldEstimate, NewEstimate, abs(NewEstimate-OldEstimate)]),
                    % SendTo2 ! {estimate, NewSS/2, NewWW/2},
                    startWork(SID, Actors, 0, NewSS/2, NewWW/2, NewEstimate)
            end
    end.
    