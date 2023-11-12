-module(records).

-export([main/0]).

-record(user, {id=-1, name="", online=-1, isFollowedBy=[], follows=[], tweets=[], mentions=[]}).
-record(tweet, {id=-1, content="", madeBy=-1, isRetweet=false, mentions=[], hashtags=[]}).

follow(Id1, Id2, Users) ->
    User1 = maps:get(Id1, Users),
    User2 = maps:get(Id2, Users),
    User1Updated = User1#user{follows = lists:append(User1#user.follows, [User2#user.id])},
    User2Updated = User2#user{isFollowedBy = lists:append(User2#user.isFollowedBy, [User1#user.id])},
    UsersUFC1 = maps:update(1, User1Updated, Users),
    UsersUFC2 = maps:update(2, User2Updated, UsersUFC1),
    UsersUFC2.

tweet(Id, Content, Tweets, Users) ->
    TweetsNew = maps:put(maps:size(Tweets)+1, #tweet{id=maps:size(Tweets)+1, content=Content, madeBy=Id, isRetweet=false, mentions=[], hashtags=[]}, Tweets),
    User1 = maps:get(Id, Users),
    User1Updated = User1#user{tweets = lists:append(User1#user.tweets,[maps:size(Tweets)+1])},
    UsersUpdated = maps:update(Id, User1Updated, Users),
    {TweetsNew, UsersUpdated}.

retweet(TweetId, UserId, Tweets, Users) ->
    RTTweet = maps:get(TweetId, Tweets),
    TweetsNew = maps:put(maps:size(Tweets)+1)

main() ->
    Users = #{1=>#user{id=1, name="us1", online=-1, isFollowedBy=[], follows=[], tweets=[], mentions=[]},
                2=>#user{id=2, name="us2", online=-1, isFollowedBy=[], follows=[], tweets=[], mentions=[]}, 
                3=>#user{id=3, name="us3", online=-1, isFollowedBy=[], follows=[], tweets=[], mentions=[]}},
    io:fwrite("~p~n",[Users]),
    Users1 = follow(1, 2, Users),
    Users2 = follow(1, 3, Users1),
    io:fwrite("~p~n",[Users2]),
    Tweets = #{},
    io:fwrite("~p~n", [Tweets]),
    {Tweets2, Users3} = tweet(1, "My First Tweet!", Tweets, Users2),
    {Tweets3, Users4} = tweet(2, "Twitter sounds exciting!", Tweets2, Users3),
    io:fwrite("~p~n", [Tweets3]),
    io:fwrite("~p~n", [Users4]).