# Leaderboards

## How it works

### Master Leaderboard
There is a global leaderboard table in PostgreSQL which holds on to all highscores for all games for all users. This however is mainly there to reconstruct the leaderboards, if they somehow gets lost.

### Sorted Global Leaderboard per Game
This is stored in Redis as a [sorted set](http://redis.io/topics/data-types) with the following key:

    "global_lb:#{game_name}"

where game_name is the unique name of the game. When a user scores their own high score for a game, the user's high score is inserted here. (As well as the master leaderboard table in Postgres.) This is a O(logN) operation.

### Sorted Friend Leaderboards per Game
Every user has a friend leaderboard per game. This is stored as a sorted set in Redis with the following key:

    "friend_lb:#{game_name}:#{user_id}"

where game_name is the unique name of the game and the user_id is the unique id of the user from Postgres. The leaderboard contains a sorted set of { friend_user_id, score } tuples.

* When a user scores a high_score, we will add the user's high_score to all their friends' leaderboards. This is a O(NlogN) operation.

* The user's newly added friends will not have the latest highscore of the user, until the user plays a new game and scores a new high_score. 

    * When a user plays the game for the first time, then we do the rather expensive operation of: 
    1. Create a sorted set of all user's friends with 0 scores.
    2. Intersect that sorted set with the global_lb for that game. 

For the first time a user's friend_lb is asked:


Other requirements:
* Whenever a new friend is added, the friend's user_id is stored in a set in Redis with the following key:

    "friends:#{user_id}"

## API
