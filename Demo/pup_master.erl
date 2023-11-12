-module(pup_master).

-export([start/0]).

start() ->
    ServerPID = changecase_server:start(),
    changecase_client:changecase(ServerPID, "Hello", uppercase),
    changecase_client:changecase(ServerPID, "Irom", uppercase),
    changecase_client:changecase(ServerPID, "Am", uppercase),
    changecase_client:changecase(ServerPID, "Yash", uppercase),
    changecase_client:changecase(ServerPID, "Shekhadar", uppercase),
    changecase_client:changecase(ServerPID, "I", uppercase),
    changecase_client:changecase(ServerPID, "only", uppercase),
    changecase_client:changecase(ServerPID, "love", uppercase),
    changecase_client:changecase(ServerPID, "coding.", uppercase).
