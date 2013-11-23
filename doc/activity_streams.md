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

The user who accepts the friendship, will have that activity registered in Postgres(in global table). That user's friends will get the activity in their activity streams. The friends' users will NOT get the activity in their own streams.