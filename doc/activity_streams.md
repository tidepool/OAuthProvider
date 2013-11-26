# Activity Streams

## Types of activities

|Actor   |Verb      |Object               |
|--------|----------|---------------------|
|User    |friends   |User                 |
|User    |highscore |Game                 |
|User    |completes |Game for all time prd| 
|User    |plays     |Game/in new time     |
|User    |gets      |PersonalityProfile   |
|User    |moves up  |Leaderboard          |
|User    |walks     |Highest steps weekday|
|User    |sleeps    |Most on a weekday    |
|User    |completes |Game for all moods   |
|User    |friend requests|User  |

And for some other features potentially coming in the future:

|Actor   |Verb      |Object               |
|--------|----------|---------------------|
|User    |wins      |Badge                |
|User    |likes     |Activity             |

## Design

### MakeFriendsActivity Model

Making friends is a dual sided activity. A user invites a friend and the friend accepts the friendship. In order to prevent double creation of the activity in the activity streams, we are using the following convention.

Example: 
UserB invites UserA
UserA accepts friend request of UserB

UserB will have the "invite friends" activity in his/her own activity stream only.
UserA will have that "now friends" activity registered in Postgres (in global activities table). UserA's friends will get the activity in their activity streams. UserB's friends will not get the activity in their activity streams, but UserB will have the activity in his/her activity stream.

## API

### Description field

The description field is a special marked up text (markdown like). The clickable areas are marked just like the markdown links:

```
      [Displayable Text](tidepool://foo/link)
```

Example:
```
      [John Doe](tidepool://user/123) is now friends with [Mary Joe](tidepool://user/3332)
```

### Endpoint:

In order to retrieve the activities for the current user:

      GET /users/-/activity_stream?limit=5&offset=0

will return:

      {
        data: [
          {
            :id => 6,
            :user_id => 5,
            :raw_data => {
              :score => 4000,
              :game_name => "snoozer"
            },
            :performed_at => "2013-11-25T17:09:09.677-08:00",
            :type => "HighScoreActivity",
            :description => "[John Doe](tidepool://user/5) scored a new highscore, 4000 in [snoozer](tidepool://game/snoozer)"
          }
        ],
        status: {
            "offset": 1,
            "limit": 2,
            "next_offset": 3,
            "next_limit": 1,
            "total": 4
        }
      }