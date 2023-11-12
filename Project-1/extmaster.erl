-module(extmaster).

-export([start/0]).

makeInitialActors(0) ->
    done.

makeInitialActors(NI, K, MasterName) ->
    spawn(extmain, startWork, [MasterName]),
    case NI > 1 of 
        true -> makeInitialActors(NI-1, K, MasterName);
        false -> makeInitialActors(0)
    end.

start() -> 
    receive
        {rise, NI, K, MasterName} ->
            makeInitialActors(NI, K, MasterName)
    end.

% router() ->
%     receive
%         {NI, K, MasterName} ->
%             start(NI, K, MasterName)
%     end.

% init() ->
%     register(extNode, spawn(extmaster, router, [])).