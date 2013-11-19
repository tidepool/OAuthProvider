## Description of the data model

### Main tables:

Users

* Some columns of interest are date_of_birth, gender, handedness and education.

Games 

* Stores the instances of all games played.
* We store many of the actions users take while playing the game in a column called event_log (TEXT - JSON). For example the snoozer game, stores all the instances of alarm clocks ringing, timings on when users tap on them and whether it was correct or not. 
* name: the unique name of the game, such as snoozer, faceoff etc.

Results - These are the game results.

* type: Identifies the type of result generated based on a game played.
    * SpeedArchetypeResult: for the snoozer game. Identifies your reaction_time and score.
    * Survey: in the beginning of the snoozer game.  
    * EmoIntelligenceResult: the emotional intelligence "FaceOff" game results.
    * PersonalityResult: 
    * Big5Result - see Big5 on Wikipedia for details. Part of initial personality game.
    * Holland6Result - see Holland6 on Wikipedia for details. Part of initial personality game.
* aggregate_results and intermediate_results columns are deprecated, do not use.
* the results are stored in score and calculations columns. Score is a HSTORE key-value store column (which can be queried fast) and the Calculations is a TEXT column that stores JSON data. 

Personalities - Detailed personality info per user

Activities - Stores the Fitbit activity data.

* Data and Goals columns have the content stored as JSON as well. Pretty self explanatory.

Sleeps - Stores the Fitbit sleep data.

* Data column stores the data as JSON. 

Measurements - Stores Fitbit provided weight and bmi information.

Foods - Stores Fitbit provided calory and water intake information

AggregateResults - Stores aggregate calculated data for users.

* type: Identifies the type of aggregate result generated:
    * SpeedAggregateResult - weekly and daily circadian rythms for the Snoozer game scores. Also the daily best, all time best etc.
    * EmoAggregateResult - This stores the reported emotion vs. how many emotions are correctly or incorrectly detected. I.e. if reported emotion is "happy", how many "sad" emotions on images are correctly detected. Also contains the daily best, all-time best etc.
    * ActivityAggregateResult - Steps per week day is recorded. This is an aggregate of all weekdays. I.e. what are most steps you took on Mondays.
    * SleepAggregateResult - Similar to Activity but for sleep.
* scores and high_scores contain the data. 
    * high_scores: HSTORE data type - high level info
    * scores: JSON datatype - detailed info

### Interview questions:

For all questions disregard data that is older than 9/10 (which was our launch day).

* Find the distribution of users based on how many times they played the snoozer game.
* Find the distribution of times the snoozer game is played (corrected by timezone) in a 24 hour bucketed by the hour. I.e. Between  9-10pm, 140 games, between 10-11pm 120 games ...
* Find the distribution of times (in 24 hr), when most users are scoring their highest scores. I.e. for a given user when is their highest score scored at? And then aggregate across all users to find the distribution. For example between 9-10pm, 130 users scored high, 10-11pm 50 users etc...
    * For the above question, divide into male and female.
    * For the above question, instead of looking at the score, look at the simple reaction time and complex reaction time.
* Find the personality (Big5 score only, i.e. for 5 dimensions) distribution of users for the number of times they play the snoozer game.
    * The same question for male and female.
    * The same for age buckets. You can come up with the age buckets based on our data.
* Find the personality distribution (Big5 only) for male and female users.



