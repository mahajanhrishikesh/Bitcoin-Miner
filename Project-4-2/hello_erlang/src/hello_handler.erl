-module(hello_handler).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
	erlang:start_timer(1000, self(), <<"Hello!">>),
	{[], State}.

websocket_handle({text, Msg}, State) ->
	{[{text, << "That's what she said! ", Msg/binary >>}], State};
websocket_handle(_Data, State) ->
	{[], State}.

websocket_info({timeout, _Ref, Msg}, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{[{text, Msg}], State};
websocket_info(_Info, State) ->
	{[], State}.

websocket_handle({text, Msg}, State) ->
	Tokens = string:tokens(binary_to_list(Msg), ">>>>"),
	Condition = lists:nth(1, Tokens),
	io:fwrite("Condition ~p",[Condition]),
	io:fwrite("Msg ~p",[Msg]),
	case Condition of 
		"Register" -> 
			% io:fwrite("Username ~p",[Tokens]),
			Uname = list_to_binary(lists:nth(2, Tokens)),
			Username = list_to_atom(lists:nth(2, Tokens)),
			Response = twitter_engine:register(Username,lists:nth(3, Tokens)),
			io:format("Response in handler ~p", [Response]),
			Key = lists:nth(1, Response),
			if
				Key == "Success" ->
					{[{text, << "Registered username: ",Uname/binary>>}], State};
				true ->
					{[{text, << Uname/binary, " already registered, try logging in.">>}], State}
			end