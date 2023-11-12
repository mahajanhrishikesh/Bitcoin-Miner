-module(changecase_client).

-export([changecase/3]).

changecase(Server, Str, Command) ->
    Server ! {self(), {Str, Command}},
    receive
        {Server, ResultString} -> 
            ResultString,
            SimonString = string:concat("Simon says ", ResultString),
            Server ! {self(), {SimonString, print}}

    end.
