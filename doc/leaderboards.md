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

For the first time a user's friend_lb is asked: -> Total: 2*O(M*log(M)) + O(2*M) + O(M)

  * Retrieve the list of all of users friend user_id's. -> O(M) where M is the number of friends.
  * Create a sorted set of all user's friends with 0 scores. -> O(M*log(M)) where M is the number of friends.
  * Intersect that sorted set with the global_lb for that game and store it in friend_lb. For intersection, we will use the MAX as the aggregate function. ->  O(M*K)+O(M*log(M)) where M is the number of friends, K is 2.
  * Record the date/time of request for caching purposes. -> O(1)

Next time the user's friend_lb is asked:

  * Check the date/time of request. If it is less than 1 minute, we serve the existing friend_lb. O(1)
  * If not, then we do the intersection of friend_lb & global_lb again. ->  O(M*K)+O(M*log(M)) where M is the number of friends, K is 2.

Other requirements:

* Whenever a new friend is added, the friend's user_id is stored in a set in Redis with the following key:

    "friends:#{user_id}"

## API

* As a user, find the global leaderboard for a given game

Call the below API by paging. The default limit and offset are 10 and 0.

    GET /api/v1/games/#{game_name}/leaderboard?offset=0&limit=10

will return in descending order (top score first)

    {
      data: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" 
          "score": "1212"
        }, {}
      ]
      status: {
        "offset": 1,
        "limit": 2,
        "next_offset": 3,
        "next_limit": 1,
        "total": 4
      }  
    }

* As a user, find the leaderboard for a given game for the friends of the calling user.

Call the below API by paging. The default limit and offset are 10 and 0.

    GET /api/v1/users/-/games/#{game_name}/leaderboard?offset=0&limit=10

will return in descending order (top score first)

    {
      data: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" 
          "score": "1212"
        }, {}
      ]
      status: {
        "offset": 1,
        "limit": 2,
        "next_offset": 3,
        "next_limit": 1,
        "total": 4
      }  
    }
