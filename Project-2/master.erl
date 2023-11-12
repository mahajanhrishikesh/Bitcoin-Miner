-module(master).

-export([
            init/3, 
            start/4, 
            makeMesh/3, 
            makeLine/3,
            makeInitialPushActors/3, 
            makeInitialGossipActors/3, 
            startGossipActor/2, 
            startPushSumActors/2
        ]).

init(NActors, Topology, Algorithm) ->
    SID = spawn(master, start, [NActors, Topology, Algorithm, []]),
    register(msid, SID),
    io:fwrite("Starting Main Process ~p...\n",[SID]),
    io:fwrite("Done.\nSetting Up Actors...\n"),
    case Algorithm of
        push_sum ->
            makeInitialPushActors(NActors, SID, []);
        gossip ->
            makeInitialGossipActors(NActors, SID, [])
    end.

makeInitialPushActors(NI, SID, Actors) ->
    CurrActor = spawn(mainPushSum, startWork, [SID, [], 0, NI, 1, 576460752303423488]),
    case NI > 0 of
        true -> 
            NewActors = lists:append([Actors, [CurrActor]]),
            makeInitialPushActors(NI-1, SID, NewActors);
        false -> 
            SID ! {allActorsMade, Actors}
    end.

makeInitialGossipActors(NI, SID, Actors) ->
    CurrActor = spawn(mainGossip, startWork, [SID, [], 0]),
    case NI > 0 of
        true -> 
            NewActors = lists:append([Actors, [CurrActor]]),
            makeInitialGossipActors(NI-1, SID, NewActors);
        false -> 
            SID ! {allActorsMade, Actors}
    end.

makeMesh(Idx, Len, ActorList) ->
    case Idx =< Len of
        true ->
            CurrNode = lists:nth(Idx, ActorList),
            ActorsCurrNode = [I || I <- ActorList],
            CurrNode ! {actors, ActorsCurrNode},
            makeMesh(Idx+1, Len, ActorList);
        false ->
            msid ! {formationComplete}
    end.

% *******************************LINE*********************************
addLineIdxs(Idx, ActorList) ->
    CurrNode = lists:nth(Idx, ActorList),
    if 
        (Idx > 1) and (Idx < length(ActorList)) ->
            CurrNode ! {actors, [lists:nth(Idx-1, ActorList),lists:nth(Idx, ActorList),lists:nth(Idx+1, ActorList)]};
        true -> 
            if (Idx == 1) ->
                    CurrNode ! {actors, [lists:nth(Idx, ActorList),lists:nth(Idx+1, ActorList)]};
                true -> 
                    if (Idx == length(ActorList)) ->
                        CurrNode ! {actors, [lists:nth(Idx-1, ActorList),lists:nth(Idx, ActorList)]};
                        true -> done
                    end 
            end
    end.


makeLine(Idx, Len, ActorList) ->
    case Idx =< Len of
        true ->
            addLineIdxs(Idx, ActorList),
            makeLine(Idx+1, Len, ActorList);
        false ->
            msid ! {formationComplete}
    end.
% *******************************END LINE*********************************

% *******************************GRID2*********************************
addGrid2dIdxs(Idx, ActorList) ->
    XOffset = 1,
    YOffset = length(ActorList)/4,
    CurrActor = lists:nth(Idx, ActorList),
    LI = Idx - XOffset,
    RI = Idx + XOffset,
    UI = Idx - YOffset,
    DI = Idx + YOffset,
    %X = ((Idx-1) rem YOffset) +1,
    %Y = floor((Idx-1) / YOffset) +1,
    if 
        (Idx rem YOffset == 0) ->
            AllNodes = [
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> if
            (Idx rem YOffset == 1) -> 
                AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> 
            AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes}
        end
    end.
    
makeGrid2d(Idx, Len, ActorList) ->
    case Idx =< Len of
        true ->
            addGrid2dIdxs(Idx, ActorList),
            makeGrid2d(Idx+1, Len, ActorList);
        false ->
            msid ! {formationComplete}
    end.
% *******************************END GRID2*********************************

% *******************************GRID2IMP*********************************
addGrid2dIdxsImp(Idx, ActorList) ->
    XOffset = 1,
    YOffset = length(ActorList)/4,
    CurrActor = lists:nth(Idx, ActorList),
    LI = Idx - XOffset,
    RI = Idx + XOffset,
    UI = Idx - YOffset,
    DI = Idx + YOffset,
    LUI = UI - 1,
    RUI = UI + 1,
    LDI = DI - 1,
    RDI = DI + 1,

    %X = ((Idx-1) rem YOffset) +1,
    %Y = floor((Idx-1) / YOffset) +1,
    if 
        (Idx rem YOffset == 0) ->
            AllNodes = [
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList),
                catch lists:nth(RUI,ActorList),
                catch lists:nth(RDI,ActorList), 
                CurrActor,
                lists:nth(rand:uniform(length(ActorList)), ActorList)
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> if
            (Idx rem YOffset == 1) -> 
                AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                catch lists:nth(LUI,ActorList),
                catch lists:nth(LDI,ActorList), 
                CurrActor,
                lists:nth(rand:uniform(length(ActorList)), ActorList)
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> 
            AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                catch lists:nth(LUI,ActorList),
                catch lists:nth(LDI,ActorList), 
                catch lists:nth(RUI,ActorList),
                catch lists:nth(RDI,ActorList), 
                CurrActor,
                lists:nth(rand:uniform(length(ActorList)), ActorList)
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes}
        end
    end.
    
makeGrid2dImp(Idx, Len, ActorList) ->
    case Idx =< Len of
        true ->
            addGrid2dIdxsImp(Idx, ActorList),
            makeGrid2dImp(Idx+1, Len, ActorList);
        false ->
            msid ! {formationComplete}
    end.
% *******************************END GRID2Imp*********************************



% *******************************GRID3*********************************
addGrid3dIdxs(Idx, ActorList) ->
    XOffset = 1,
    YOffset = length(ActorList)/3,
    ZOffset = length(ActorList)/3 * length(ActorList)/3,
    CurrActor = lists:nth(Idx, ActorList),
    LI = Idx - XOffset,
    RI = Idx + XOffset,
    UI = Idx - YOffset,
    DI = Idx + YOffset,
    FI = Idx + ZOffset,
    BI = Idx - ZOffset,
    %X = ((Idx-1) rem YOffset) +1,
    %Y = floor((Idx-1) / YOffset) +1,
    if 
        (Idx rem YOffset == 0) ->
            AllNodes = [
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                catch lists:nth(FI,ActorList), 
                catch lists:nth(BI,ActorList), 
                lists:nth(rand:uniform(length(ActorList)), ActorList),
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> if
            (Idx rem YOffset == 1) -> 
                AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList),
                catch lists:nth(FI,ActorList), 
                catch lists:nth(BI,ActorList),
                lists:nth(rand:uniform(length(ActorList)), ActorList), 
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes};
        true -> 
            AllNodes = [
                catch lists:nth(RI,ActorList),
                catch lists:nth(LI,ActorList),
                catch lists:nth(UI,ActorList),
                catch lists:nth(DI,ActorList), 
                catch lists:nth(FI,ActorList), 
                catch lists:nth(BI,ActorList),
                lists:nth(rand:uniform(length(ActorList)), ActorList),
                CurrActor
            ],
            AllValidNodes = [I || I <- AllNodes, is_pid(I)],
            CurrActor ! {actors, AllValidNodes}
        end
    end.
    
makeGrid3d(Idx, Len, ActorList) ->
    case Idx =< Len of
        true ->
            addGrid3dIdxs(Idx, ActorList),
            makeGrid3d(Idx+1, Len, ActorList);
        false ->
            msid ! {formationComplete}
    end.
% *******************************END GRID3*********************************

startGossipActor(ActorList, K) ->
    case K > 0 of
        true->
            lists:nth(rand:uniform(length(ActorList)), ActorList) ! {rumour,"DOSP is easy."},
            startGossipActor(ActorList, K-1);
        false ->
            done
    end.

startPushSumActors(ActorList, K) ->
    case K > 0 of
        true->
            RandIdx = rand:uniform(length(ActorList)),
            lists:nth(RandIdx , ActorList) ! {starter},
            startPushSumActors(ActorList, K-1);
        false ->
            done
    end.

updateActors(Idx, NewActors) ->

    case Idx =< length(NewActors) of
        true ->
            CurrNode = lists:nth(Idx, NewActors),
            CurrNode ! {updateActors, NewActors},
            updateActors(Idx+1, NewActors);
        false -> done
    end.


start(NActors, Topology, Algorithm, Actors) ->
    receive
        {allActorsMade, NewActors} ->
            io:fwrite("Done.\nAssembling Actors...\n"),
            case Topology of 
                mesh -> 
                    makeMesh(1, length(NewActors), NewActors),
                    io:fwrite("Done.\nActors are in mesh formation...\n"),
                    start(NActors, Topology, Algorithm, NewActors);
                line ->
                    makeLine(1, length(NewActors), NewActors),
                    io:fwrite("Done.\nActors are in line formation...\n"),
                    start(NActors, Topology, Algorithm, NewActors);
                grid2d ->
                    makeGrid2d(1, length(NewActors), NewActors),
                    io:fwrite("Done.\nActors are in grid2d formation...\n"),
                    start(NActors, Topology, Algorithm, NewActors);
                grid3d -> 
                    makeGrid3d(1, length(NewActors), NewActors),
                    io:fwrite("Done.\nActors are in grid3d formation...\n"),
                    start(NActors, Topology, Algorithm, NewActors)
            end;
        {formationComplete} ->
            io:format("Start : ~p \n", [erlang:timestamp()]),
            case Algorithm of
                gossip ->
                    startGossipActor(Actors, floor(length(Actors)/4)),
                    % io:format("Done.\nActors are in ~p formation...\n", [atom_to_list(Topology)]),
                    start(NActors, Topology, Algorithm, Actors);
                push_sum ->
                    startPushSumActors(Actors, floor(length(Actors)/4)),
                    % io:format("Done.\nActors are in ~p formation...\n", [atom_to_list(Topology)]),
                    start(NActors, Topology, Algorithm, Actors)
            end;
        {rumourHeard, APID} ->
            %io:format("~p going offline.\n", [APID]),
            NewActors = [I || I <- Actors, I/=APID],
            updateActors(1, NewActors),
            startGossipActor(NewActors, floor(length(Actors)/4)),
            if (length(NewActors) < floor(0.05*NActors)) ->
                io:format("~p", [erlang:timestamp()]),
                exit(whereis(msid), ok);
                true-> done
            end,
            start(NActors, Topology, Algorithm, NewActors);
        {estimateHeard, APID, Estimate} ->
            %io:format("~p going offline with ~p.\n", [APID, Estimate]),
            NewActors = [I || I <- Actors, I/=APID],
            updateActors(1, NewActors),
            %startPushSumActors(NewActors, floor(length(Actors)/4)),
            if (length(NewActors) < 50) and (length(NewActors) > 1) ->
                    startPushSumActors(NewActors, length(Actors));
                true ->
                    if length(NewActors) == 0 ->
                        io:format("Exit : ~p \n", [erlang:timestamp()]),
                        exit(whereis(msid), ok);
                        true -> done
                    end
            end,
            start(NActors, Topology, Algorithm, NewActors);
        {whoIsAlive} ->
            io:format("~p\n", [Actors]),
            start(NActors, Topology, Algorithm, Actors)
    end.