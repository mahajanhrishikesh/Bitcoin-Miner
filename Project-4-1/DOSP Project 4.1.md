## COP5615 - Project 4 - Part 1
### Twitter Clone with a Client Tester & Simulator
##### Group Members
- Hrishikesh Mahajan
- Yash Shekhadar

#### Functionalities Implemented in the Twitter Engine
- Registration of a New Account
- User generates a tweet that can contain text, mentions of other users and hashtags
- A user can follow any other existing user
- Functionality to re-tweet a tweet made by a user you follow so that it is populated in the feed of the users that follow you
- Fetch the tweets belonging to a user or tweets containing a specific hashtag or a tweets containing the mention of a specific user
- Users going online and offline randomly. Once the user comes online, their feed is populated with the tweets that were created when the user was offline

#### Functionalities Implemented in the Simulator:
- Simulation of as many users as we want (100-10000)
- Simulation of users going offline and online periodically
- The number of followers of each user is computed using a zipf distribution
- Making sure that the account with more followers have more tweets

#### Max Number of Users Tested: 5000