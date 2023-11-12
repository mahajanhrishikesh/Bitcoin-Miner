-module(engine).

-export([makeEnv/1, 
        makeUsers/4, 
        makeFollowers/4, 
        assignFollowers/4, 
        follow/3,
        release/4, 
        simulation/4]).

-record(user, {id=-1, name="", online=list_to_pid("<0.0.0>"), isFollowedBy=[], follows=[], tweets=[], mentions=[]}).
-record(tweet, {id=-1, content="", madeBy=-1, isRetweet=false, mentions=[], hashtags=[]}).

makeUsers(SID, I, NUsers, Users) ->
    NewUsers = maps:put(I, #user{id=maps:size(Users), name=lists:flatten(io_lib:format("~s~p",["u",I])), online=list_to_pid("<0.0.0>"), isFollowedBy=[], follows=[], tweets=[], mentions=[]}, Users),
    case I < NUsers of
        true -> 
            makeUsers(SID, I+1, NUsers, NewUsers);
        false -> 
            SID ! {madeUsers, Users}
    end.

follow(Id1, Id2, Users) ->
    User1 = maps:get(Id1, Users),
    User2 = maps:get(Id2, Users),
    User1Updated = User1#user{follows = lists:append(User1#user.follows, [User2#user.id])},
    User2Updated = User2#user{isFollowedBy = lists:append(User2#user.isFollowedBy, [User1#user.id])},
    UsersUFC1 = maps:update(Id1, User1Updated, Users),
    UsersUFC2 = maps:update(Id2, User2Updated, UsersUFC1),
    UsersUFC2.

assignFollowers(I, NumFollowers, Id, CurrUsers) ->
    %io:format("YABADABADOO~p~n",[maps:size(CurrUsers)]),
    case I < NumFollowers of
        true ->
            RIdx = rand:uniform(maps:size(CurrUsers)-1),
            io:format("~p ~p ~n",[Id, RIdx]),
            NewUsers = follow(Id, RIdx, CurrUsers),
            assignFollowers(I+1, NumFollowers, Id, NewUsers);
        false ->
            CurrUsers
    end.

makeFollowers(SID, I, NUsers, Users) ->
    %io:format("NAI3~p ~p", [I, Users]),
    if (I =< NUsers*0.1)->
            NewUsers = assignFollowers(0, 250, I, Users),
            makeFollowers(SID, I+1, NUsers, NewUsers);
        (I > NUsers*0.1) and (I =< NUsers*0.2) ->
            NewUsers2 = assignFollowers(0, 165, I, Users),
            makeFollowers(SID, I+1, NUsers, NewUsers2);
        (I > NUsers*0.2) and (I =< NUsers*0.4)->
            NewUsers3 = assignFollowers(0, 108, I, Users),
            makeFollowers(SID, I+1, NUsers, NewUsers3);
        (I > NUsers*0.4) and (I =< NUsers*0.8) ->
            NewUsers4 = assignFollowers(0, 71, I, Users),
            makeFollowers(SID, I+1, NUsers, NewUsers4);
        (I > NUsers*0.8) and (I < NUsers*1.0) ->
            NewUsers5 = assignFollowers(0, 47, I, Users),
            makeFollowers(SID, I+1, NUsers, NewUsers5);
        (I>=NUsers)->
            SID ! {followMeshed, Users};
        true->
            1+1
    end.


makeEnv(NUsers) ->
    Users = #{},
    Tweets = #{},
    Hashtags = #{},
    SID = spawn(engine, simulation, [Users, Tweets, Hashtags, 0]),
    register(msid, SID),
    io:format("~p",[SID]),
    makeUsers(SID, 0, NUsers, Users).

bringOnline(SID, Id, Users) ->
    User = maps:get(Id, Users),
    ID = spawn(tweeter, active, [SID, User, maps:size(Users)]),
    ID!{marco},
    UpdatedUser = User#user{online=ID},
    UpdatedUsers = maps:update(Id, UpdatedUser, Users),
    UpdatedUsers.

release(SID, I, Total, Users) ->
    case I < Total of
        true ->
            NewUsers = bringOnline(SID, I, Users),
            release(SID, I+1, Total, NewUsers);
        false ->
            SID ! {birdsInTheSky, Users}
    end.



simulation(Users, Tweets, Hashtags, NumOnline) ->
    receive
        {madeUsers, NewUsers} ->
            % io:format("~p~n",[NewUsers]),
            makeFollowers(self(), 0, maps:size(NewUsers), NewUsers),
            simulation(NewUsers, Tweets, Hashtags, NumOnline);
        {followMeshed, NewUsers} ->
            % io:format("FINAL~p~n",[NewUsers]),
            release(self(), 0, maps:size(NewUsers), NewUsers),
            simulation(NewUsers, Tweets, Hashtags, NumOnline);
        {birdsInTheSky, NewUsers} ->
            % io:format("Online Users: ~p~n",[NewUsers]),
            simulation(NewUsers, Tweets, Hashtags, maps:size(Users));
        {polo, ID} ->
            % io:format("User ~p is online.~n",[ID]),
            simulation(Users, Tweets, Hashtags, NumOnline);
        {addTweet2Hashtag, TweetId, HashTag} ->
            case maps:is_key(HashTag, Hashtags) of 
                true ->
                    maps:update(HashTag, lists:append(maps:get(HashTag, Hashtags), [TweetId]), Hashtags);
                false ->
                    maps:put(HashTag, [TweetId], Hashtags)
            end,
            simulation(Users, Tweets, Hashtags, NumOnline);
        {addTweet2Mentions, TweetId, UserId} -> 
            User = maps:get(UserId, Users),
            UserUpdated = lists:append(User#user.mentions, [TweetId]),
            UsersUpdated = maps:update(UserId, UserUpdated, Users),
            simulation(UsersUpdated, Tweets, Hashtags, NumOnline);
        {req2getAllHashedTweets, ReqPID, HashTag} ->
            ReqTweetIds = maps:get(HashTag, Hashtags),
            ReqPID ! {hereAreYourHashTweets, [maps:get(I, Tweets) || I <- ReqTweetIds]},
            simulation(Users, Tweets, Hashtags, NumOnline);
        {reqMyMentions, ReqPID, UID} ->
            ReqUser = maps:get(UID, Users),
            ReqPID ! {hereAreYourMentions, [maps:get(I, Tweets) || I <- ReqUser#user.mentions]},
            simulation(Users, Tweets, Hashtags, NumOnline);
        {reqTweetOfUser, ReqPID, UID} ->
            ReqUser = maps:get(UID, Users),
            ReqPID ! {hereAreYourUserTweets, [maps:get(I, Tweets) || I <- ReqUser#user.tweets]},
            simulation(Users, Tweets, Hashtags, NumOnline);
        {tweet, UserId, Tweet} ->
            TweetChunks = string:tokens(io_lib:format("~s", [Tweet#tweet.content]), " "),
            AllMentions = [list_to_integer(lists:sublist(I, 2, length(I)))||I<-TweetChunks, lists:sublist(I, 1) == "@"],
            AllHashTags = [lists:sublist(I, 2, length(I))||I<-TweetChunks, lists:sublist(I, 1) == "#"],
            TweetsNew = maps:put(maps:size(Tweets)+1, Tweet, Tweets),
            [self() ! {addTweet2Mentions, maps:size(TweetsNew), I} || I <- AllMentions],
            [self() ! {addTweet2Hashtag, maps:size(TweetsNew), I} || I<- AllHashTags],
            User1 = maps:get(UserId, Users),
            User1Updated = User1#user{tweets = lists:append(User1#user.tweets,[maps:size(Tweets)+1])},
            UsersUpdated = maps:update(UserId, User1Updated, Users),
            SpreadTweet = [maps:get(I, Users) || I <- User1Updated#user.isFollowedBy],
            [I#user.online ! {displayTweet, Tweet} || I <- SpreadTweet, I#user.online=/="<0.0.0>"],
            simulation(UsersUpdated, TweetsNew, Hashtags, NumOnline);
        {register, Username} ->
            NewUsers = maps:put(maps:size(Users), #user{id=maps:size(Users), name=Username, online=list_to_pid("<0.0.0>"), isFollowedBy=[], follows=[], tweets=[], mentions=[]}, Users),
            % io:format("Registered ~p.", [Username]),
            simulation(NewUsers, Tweets, Hashtags, NumOnline);
        {showUsers} ->
            % io:format("~p~n", [Users]),
            simulation(Users, Tweets, Hashtags, NumOnline);
        {requestRandomTweet, ReqPID, Id} ->
            ReqUser = maps:get(Id, Users),
            TweetsLen = length(ReqUser#user.tweets),
            case TweetsLen > 0 of
                false -> 
                    simulation(Users, Tweets, Hashtags, NumOnline);
                true ->
                    User = maps:get(Id, Users),
                    Tweet = maps:get(lists:nth(rand:uniform(length(User#user.tweets)), User#user.tweets), Tweets),
                    ReqPID!{reqTweet, Tweet},
                    simulation(Users, Tweets, Hashtags, NumOnline)
            end;
        {retweet, Uid, Tweet} ->
            ModTweet = Tweet#tweet{madeBy=Uid, isRetweet=Tweet#tweet.madeBy},
            TweetsNew = maps:put(maps:size(Tweets)+1, ModTweet, Tweets),
            User1 = maps:get(Uid, Users),
            User1Updated = User1#user{tweets = lists:append(User1#user.tweets,[maps:size(Tweets)+1])},
            UsersUpdated = maps:update(Uid, User1Updated, Users),
            %io:format("~p~n",[TweetsNew]),
            SpreadTweet = [maps:get(I, Users) || I <- User1Updated#user.isFollowedBy],
            [I#user.online ! {displayReTweet, ModTweet} || I <- SpreadTweet],
            simulation(UsersUpdated, TweetsNew, Hashtags, NumOnline);
        {loggingOff, UID} ->
            ReqUser = maps:get(UID, Users),
            ReqUserUpdated = ReqUser#user{online="<0.0.0>"},
            UsersUpdated = maps:update(UID, ReqUserUpdated, Users),
            % io:format("Logged Off ~p.~n", [UID]),
            case NumOnline < maps:size(Users)*0.5 of 
                true ->
                    release(self(), 0, maps:size(UsersUpdated), UsersUpdated),
                    io:format("Num Users: ~p~nNum Tweets:~p~n", [maps:size(Users), maps:size(Tweets)]),
                    simulation(UsersUpdated, Tweets, Hashtags, NumOnline-1);
                false ->
                    simulation(UsersUpdated, Tweets, Hashtags, NumOnline-1)
            end
        % {bind2me, PID, UID} ->
        %     User1 = maps:get(UID, Users),
        %     User1Updated = User1#user{},
        %     UsersUpdated = maps:update(Uid, User1Updated, Users),
    end.