-module(engine).

-export([register/1, tweet/2, retweet/3, userActive/3]).

register(Username) ->
    io:format("Registering user with name ~p. ~n", [Username]).

tweet(Username, Tweet) ->
    % Split with spaces, process words that start with '#' and '@' seperately
    io:format("User ~p tweeted '~p'. ~n", [Username, Tweet]).

retweet(Tweeter, Tweety, Tweet) ->
    io:format("User ~p retweeted ~p's tweet: ~p", [Tweeter, Tweety, Tweet]).

getSubscribedTweets() ->
    exit.

userActive(Master, Username, Following, Tweets) ->
    Master ! {online, self()},
    receive
        {tweet, Tweet} ->
            tweet(Username, Tweet),
            userActive(Master, Username, Following);
        {subscribe, Username} ->
            Master ! {addSubscriber, self(), Username},
            userActive(Master, Username, Following);
        {retweet, Username, Tweet} ->
            retweet(self(), Username, Tweet),
            userActive(Master, Username, Following);
        {query, subsrcibedTweets} ->
            getSubscribedTweets(),
            userActive(Master, Username, Following);
        {logout} ->
            io:format("User has logged out.")
    end.
