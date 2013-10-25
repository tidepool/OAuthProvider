POST /users/-/friends/invite 

{ 
  friend_list: {
    emails: [ 'foo@foo.com', 'bar@bar.com' ],
    facebook_ids: ['213213131', "2121" ]
  }
}

(Do not replicate the email and Facebook id for the same user. Give me either one but not both)

Implementation:

0. Will keep a list of all user's emails and facebook_ids in Redis, as a set.
1. Check if the invited list exists against that set. Basically a O(N) operation. N O(1) lookups, as set lookups are only O(1). And I can also pipeline this so that I am not sending network request for each lookup. So all happens in Redis at once and comes back.
2. Add the found people to the (M) to the pending list in Redis. Each entry will have a key like "pending_emails:foo@foo.com" or "pending_facebook_ids:1212123". The entries will be of the type set, where the user_id of the person invited the user will be stored in that set. If someone else has invited that user before, the new inviter's user_id will be added to the existing set.
3. Add the not found invited people (N-M) in Redis. Each entry will have a key like "invited_emails:foo@foo.com" or "invited_facebook_ids:1212123". The entries will be of the type set, where the user_id of the person invited the user will be stored in that set. If someone else has invited that user before, the new inviter's user_id will be added to the existing set.

GET /users/-/friends

returns

GET /users/-/friends?pending=true

returns:
{
  friend_list: [


  ]  
}


POST /users/-/friends/accept

{
  friend_list: {
    user_ids: [ 'id1', 'id2' ]
  }
}


4. Whenever someone joins TidePool, I will look up the invited people keys in Redis. If I found an entry, that will give me the set of people who invited that person. Then I will create the Friendship table with this. And I will also remove that invited user key from Redis.  


5. The friendship table will be initially created with friend_status=pending. I will be giving you an API which basically lets you query the Friendship table. When you see a friend_status pending, you should provide a UI to activate that friendship. (friend_status=active, which will be a PUT back to that Friendship. Details will be send soon) Basically we will need to provide the equivalent of "Joe wants to be friends with you.. Accept?" If it is not accepted, then we will delete that friendship.