-module(tweeter).

-export([active/3, queueRandomActions/2]).

-record(user, {id=-1, name="", online=-1, isFollowedBy=[], follows=[], tweets=[], mentions=[]}).
-record(tweet, {id=-1, content="", madeBy=-1, isRetweet=false, mentions=[], hashtags=[]}).

queueRandomActions(PID, N) ->
    Actions = [tweet, tweetWithHashtag, tweetWithMention, retweet, req2getAllUserTweets, req2getAllMentions, req2getAllHashtagMentions],
    PID ! {lists:nth(rand:uniform(length(Actions)), Actions)},
    case N > 0 of
        true -> 
            queueRandomActions(self(), N-1);
        false ->
            ok
    end.

generateActions(PID, N) ->
    Actions = [tweet, retweet],
    PID ! {lists:nth(rand:uniform(length(Actions)), Actions)},
    case N > 0 of
        true -> 
            generateActions(self(), N-1);
        false ->
            ok
    end.

active(SID, User, NUsers) ->
    %ATTENTION: USER RECORD USED TO INVOKE THIS FUNCTION HAS NO VALID ONLINE FIELD
    Subjects = ["I", "He", "She"],
    Verbs = ["read", "study", "like", "love"],
    Objects = ["c++", "python", "java", "html", "cricket", "apples", "oranges"],
    HashTags = ["#bigdata", "#blockchain", "#iot", "#5g", "#machinelearning", "#ai", "#industry4"],
    receive 
        {marco} ->
            SID ! {polo, User#user.id},
            I = User#user.id,
            if (I =< NUsers*0.1)->
                    generateActions(self(), 25);
                (I > NUsers*0.1) and (I =< NUsers*0.2) ->
                    generateActions(self(), 17);
                (I > NUsers*0.2) and (I =< NUsers*0.4)->
                    generateActions(self(), 10);
                (I > NUsers*0.4) and (I =< NUsers*0.8) ->
                    generateActions(self(), 7);
                (I > NUsers*0.8) and (I < NUsers*1.0) ->
                    generateActions(self(), 5);
                true->
                    1+1
            end,
            self()!{tweet},
            self()!{retweet},
            self()!{tweetWithHashtag},
            self()!{tweetWithMention},
            self()!{req2getAllUserTweets},
            self()!{req2getAllMentions},
            self()!{smileAndWave},
            self()!{req2getAllHashedTweets},
            active(SID, User, NUsers);
        {smileAndWave} -> 
            queueRandomActions(self(), rand:uniform(10)),
            self()!{logout},
            active(SID, User, NUsers);
        {tweet} ->
            Words = [lists:nth(rand:uniform(length(I)), I) || I <- [Subjects, Verbs, Objects]],
            Tweet = #tweet{id=-1, content=lists:nth(1,Words)++" "++lists:nth(2,Words)++" "++lists:nth(3, Words), madeBy=User#user.id, isRetweet=false, mentions=[], hashtags=[]},
            % io:format(Tweet#tweet.content),
            SID ! {tweet, User#user.id, Tweet},
            active(SID, User, NUsers);
        {tweetWithHashtag} ->
            Words = [lists:nth(rand:uniform(length(I)), I) || I <- [Subjects, Verbs, Objects, HashTags]],
            Tweet = #tweet{id=-1, content=lists:nth(1,Words)++" "++lists:nth(2,Words)++" "++lists:nth(3, Words)++" "++lists:nth(4, Words), madeBy=User#user.id, isRetweet=false, mentions=[], hashtags=[]},
            SID ! {tweet, User#user.id, Tweet},
            active(SID, User, NUsers);
        {tweetWithMention} ->
            Words = [lists:nth(rand:uniform(length(I)), I) || I <- [Subjects, Verbs, Objects, lists:append(User#user.isFollowedBy, User#user.follows)]],
            Tweet = #tweet{id=-1, content=lists:nth(1,Words)++" "++lists:nth(2,Words)++" "++lists:nth(3, Words)++" @"++integer_to_list(lists:nth(4, Words)), madeBy=User#user.id, isRetweet=false, mentions=[], hashtags=[]},
            SID ! {tweet, User#user.id, Tweet},
            active(SID, User, NUsers);
        {retweet} ->
            SID ! {requestRandomTweet, self(), lists:nth(rand:uniform(length(User#user.follows)), User#user.follows)},
            active(SID, User, NUsers);
        {reqTweet, Tweet} ->
            SID ! {retweet, User#user.id, Tweet},
            active(SID, User, NUsers);
        {displayTweet, Tweet} ->
            % io:format("User ~p FEED: ~p tweeted: ~p.~n",[User#user.id, Tweet#tweet.madeBy, Tweet#tweet.content]),
            active(SID, User, NUsers);
        {displayReTweet, Tweet} ->
            % io:format("User ~p FEED: ~p retweeted tweet of ~p saying ~p.~n",[User#user.id, Tweet#tweet.madeBy, Tweet#tweet.isRetweet, Tweet#tweet.content]),
            active(SID, User, NUsers);
        {req2getAllUserTweets} ->
            SID ! {reqTweetOfUser, self(), lists:nth(rand:uniform(length(User#user.follows)), User#user.follows)},
            active(SID, User, NUsers);
        {hereAreYourUserTweets, UserTweets} ->
            % io:format("Requested Tweets: ~p~n", [UserTweets]),
            active(SID, User, NUsers);  
        {req2getAllMentions} ->
            SID ! {reqMyMentions, self(), User#user.id},
            active(SID, User, NUsers);
        {req2getAllHashtagMentions} ->
            RandomHash = lists:nth(rand:uniform(length(HashTags), HashTags)),
            SID ! {req2getAllHashedTweets, self(), string:substr(RandomHash, 2, length(RandomHash))},
            active(SID, User, NUsers);
        {hereAreYourMentions, MentioningTweets} ->
            % io:format("You were mentioned in the following tweets: ~p~n", [MentioningTweets]),
            active(SID, User, NUsers);
        {hereAreYourHashTweets, HashTweets} ->
            active(SID, User, NUsers);
        {logout} -> 
            SID ! {loggingOff, User#user.id}
            % io:format("User ~p is requesting to log out.~n", [User#user.id])
    end.