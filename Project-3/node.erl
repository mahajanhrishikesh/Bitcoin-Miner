-module(node).

-export([start/7, look/7]).

look(GFather, Father, LookupEntries, Idx, Key, Hop, EnumeratedHash2PID) ->
    % LookUpPID = maps:from_list(Hash2PID),
    
    if length(LookupEntries) =/= 0 ->
        if(Idx == length(LookupEntries)-1) ->
            element(2, lists:nth(length(LookupEntries), LookupEntries)) ! {lookup, Key, Hop+1};
            true ->
                NodeHash = element(1, lists:nth(Idx, LookupEntries)),
                NextNodeHash = element(1, lists:nth(Idx+1, LookupEntries)),
                KeyMinusNode = Key - NodeHash,
                NextNodeMinusNode = NextNodeHash - NodeHash,
                CurrNodeIdx = element(1, element(2, lists:keysearch(NodeHash, 2, EnumeratedHash2PID))),
                NextNaturalNodeHash = element(2, lists:nth(CurrNodeIdx+1, EnumeratedHash2PID)),
                NextNodeMinusNextNaturalNode = NextNaturalNodeHash - NodeHash,
                if ((KeyMinusNode < NextNodeMinusNode) and (KeyMinusNode < NextNodeMinusNextNaturalNode))->
                    GFather ! {found, Hop}; 
                    true ->
                        look(GFather, Father, LookupEntries, Idx+1, Key, Hop, EnumeratedHash2PID)
                    end
        end;
        true ->
            done
    end.
    % if (Idx == length(LookupEntries)-1) ->
    %     done;
    % true ->
        % CurrHash = element(1, lists:nth(Idx, LookupEntries)),
        % io:format("~p, ~p, ~p ~n", [CurrHash, Key, NextHash]),
        % if (CurrHash < Key) and (Key < NextHash) -> 
        %     GFather ! {found, Hop};
        % true ->
        %     if (Key < CurrHash) ->
        %         element(2, lists:nth(Idx - 1, LookupEntries)) ! {lookup, Key, Hop+1};
        %     true ->
        %         look(GFather, Father, LookupEntries, Idx+1, Key, Hop)
        %     end
        % end.
    % end.

makeRequests(AID, Limits, NumQueries) ->
    MinLimit = element(1, Limits),
    MaxLimit = element(2, Limits),
    RandomNum = MinLimit + rand:uniform(MaxLimit - MinLimit),
    %io:format("~p ~p ~p ~n", [MinLimit, RandomNum, MaxLimit]),
    AID ! {lookup, RandomNum, 1},
    if NumQueries > 0 ->
        makeRequests(AID, Limits, NumQueries-1);
    true ->
        ok
    end.

start(SID, NumNodes, NumQueries, Limits, Hash2PID, MyDX, EnumeratedHash2PID) ->
    receive
        {getFingerTable, NewHash2PID} ->
            MaxLimit = element(1, lists:max(NewHash2PID)),
            MinLimit = element(1, lists:min(NewHash2PID)),
            Seq = lists:seq(1, length(NewHash2PID)),
            NewEnumeratedHash2PID = [{I, element(1, lists:nth(I, NewHash2PID)), element(2, lists:nth(I, NewHash2PID))}||I<-Seq],
            NewDx = element(1, element(2,lists:keysearch(self(), 3, NewEnumeratedHash2PID))),
            start(SID, NumNodes, NumQueries, {MinLimit, MaxLimit}, NewHash2PID, NewDx, NewEnumeratedHash2PID);
        {showActors} ->
            io:format("~p ~p ~n", [lists:keysearch(self(), 2, Hash2PID), MyDX]),
            io:format("~p~n", [Hash2PID]),
            start(SID, NumNodes, NumQueries, Limits, Hash2PID,MyDX, EnumeratedHash2PID);
        {startRequests} ->
            makeRequests(self(), Limits, NumQueries),
            start(SID, NumNodes, NumQueries, Limits, Hash2PID,MyDX, EnumeratedHash2PID);
        {lookup, Key, Hop} ->
            Offsets = [round(math:pow(2,I))|| I <- lists:seq(0, round(math:floor(math:log2(NumNodes))))],
            NegOffsetsRev = [-I || I <- Offsets],
            NegOffsets = lists:reverse(NegOffsetsRev),
            TotalOffsets = lists:append([NegOffsets, Offsets]),
            LookupIdxs = [MyDX+I||I <- TotalOffsets, ((MyDX+I >= 1) and (MyDX+I=<NumNodes))],
            LookupEntries = [lists:nth(I, Hash2PID)||I<-LookupIdxs],
            %io:format("~p ~p ~p ~p ~p ~p ~p ~n", [MyDX, Offsets, NegOffsetsRev, NegOffsets, TotalOffsets, LookupIdxs, LookupEntries]),
            spawn(node, look, [SID, self(), LookupEntries, 1, Key, Hop, EnumeratedHash2PID]),
            start(SID, NumNodes, NumQueries, Limits, Hash2PID,MyDX, EnumeratedHash2PID)
    end.