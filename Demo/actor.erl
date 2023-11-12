-module(actor).

-export([chad/1]).

chad(0)->
    ok;

chad(N)->
    io:format("~p ~n",[N]).
    
