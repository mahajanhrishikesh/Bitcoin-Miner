-module(simulator).

-export([setup/2, simulation/4, registerAllUsers/3, makeFollowerMesh/4]).

setup(NUsers, MeanFollowers)->
    SID = spawn(simulator, simulation, [#{}, #{}, NUsers, MeanFollowers]),
    Users = #{},
    Tweets = #{},
    registerAllUsers(SID, NUsers, Users).

registerAllUsers(SID, NUsers, Users) ->
    NewUsers = maps:put(NUsers, #{"Name"=>lists:flatten(io_lib:format("~s~p",["u",NUsers])),"tweets"=>[],"isOnline"=>-1,"mentions"=>[]},Users),
    case NUsers > 0 of
        true -> 
            registerAllUsers(SID, NUsers-1, NewUsers);
        false -> 
            SID ! {usersMade, NewUsers}
    end.

makeFollowerMesh(SID, NUsers, Users, MeanFollowers)->
    %(1/(2*math:sqrt(2*3.14159)))*(math:pow(2.71828, -((1/2)*math:pow(((2-5)/2), 2)))).
    S1 = [0, MeanFollowers - 3*MeanFollowers/5],
    S2 = [MeanFollowers - 3*MeanFollowers/5, MeanFollowers - 2*MeanFollowers/5],
    S3 = [MeanFollowers - 2*MeanFollowers/5, MeanFollowers - 1*MeanFollowers/5],
    S4 = [MeanFollowers - 1*MeanFollowers/5, MeanFollowers - 0*MeanFollowers/5],
    S5 = [MeanFollowers - 0*MeanFollowers/5, MeanFollowers + 1*MeanFollowers/5],
    S6 = [MeanFollowers + 1*MeanFollowers/5, MeanFollowers + 2*MeanFollowers/5],
    S7 = [MeanFollowers + 2*MeanFollowers/5, MeanFollowers + 3*MeanFollowers/5],
    S8 = [MeanFollowers + 3*MeanFollowers/5, NUsers],
    SID ! {print, io_lib:format("~p,~p,~p,~p,~p,~p,~p,~p", [S1,S2,S3,S4,S5,S6,S7,S8])},



makeFollowerMesh(SID, I, TotalUsers, MeanFollowers, Mesh) ->
    case I of
        (I >= 0) && (I < TotalUsers*0.0015) -> 
            NewMesh = maps:put(I, [[random:uniform(TotalUsers)||_<-lists:seq(0+random:uniform(MeanFollowers - 3*MeanFollowers/5))], []], Mesh)
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers, NewMesh);
        (I > TotalUsers*0.0015) && (I < TotalUsers*0.0225) ->
            generateFollowers(I, MeanFollowers - 3*MeanFollowers/5, MeanFollowers - 2*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers*0.0225) && (I < TotalUsers*0.1585) ->
            generateFollowers(I, MeanFollowers - 2*MeanFollowers/5, MeanFollowers - 1*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers*0.1585) && (I < TotalUsers*0.4995) ->
            generateFollowers(I, MeanFollowers - 1*MeanFollowers/5, MeanFollowers - 0*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers*0.4995) && (I < TotalUsers*0.8405) ->
            generateFollowers(I, MeanFollowers - 0*MeanFollowers/5, MeanFollowers + 1*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers*0.8405) && (I < TotalUsers*0.9765) ->
            generateFollowers(I, MeanFollowers + 1*MeanFollowers/5, MeanFollowers + 2*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers*0.9765) && (I < TotalUsers*0.9975) ->
            generateFollowers(I, MeanFollowers + 2*MeanFollowers/5, MeanFollowers + 3*MeanFollowers/5),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > 0.9975) && (I <= TotalUsers) ->
            generateFollowers(I, MeanFollowers + 3*MeanFollowers/5, TotalUsers),
            makeFollowerMesh(SID, I, TotalUsers, MeanFollowers);
        (I > TotalUsers) ->
            SID ! {followMeshed, Mesh}
    end.



simulation(Users, Tweets, NUsers, MeanFollowers) ->
    io:format("~p", [self()]),
    receive
        {usersMade, NewUsers} ->
            % io:format("~p HAHAHA",[Users]),
            makeFollowerMesh(self(), NUsers, NewUsers, MeanFollowers),
            simulation(NewUsers, Tweets, NUsers, MeanFollowers);
        {followMeshed, Users, Tweets} ->
            simulation(Users, Tweets, NUsers, MeanFollowers);
        {flock} -> 
            % Create sizeable amount of tweets randomly for random
            % amount of users
            simulation(Users, Tweets, NUsers, MeanFollowers);
        {print, Message} ->
            io:format("~s", [Message]),
            simulation(Users, Tweets, NUsers, MeanFollowers)
    end.