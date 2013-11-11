# Friends API

* As a user, find if your friends (Facebook or email based) are already in TidePool.

Upload the list of emails and/or Facebook IDs you want to search for: (You would need to page this on your end so that you are not uploading more than 20 at a time.)

    GET /api/v1/users/-/friends/find? 

in the query params:

    ?email[]=foo@foo.com&email[]=bar@bar.com&
    fbid[]=12312313&fbid[]=654646454


returns: 

    {
      data: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" }, 
          {} 
      ],
      status: {
        "total": 4 
      }
    }

* As a user, select a few of the found friends and invite them as friends in TidePool.

Using the same data that is found in step 1 above, submit the selected users:

    POST /api/v1/users/-/friends/invite

in the body of HTTP request:

    {
      friend_list: [
        {
           "id": "74",
           "name": "Mary12 Doe",
           "email": "spec_user66@example.com",
           "image": "http://example.com/image12.jpg" 
        }
      ]
    }

returns status 202 and empty body. At this point, the friends are invited and pending acceptance from them. (They are not your friends until they accept.)

* As a user, I would like to see pending friend requests.

Call the below API by paging. The default limit and offset are 20 and 0.

    GET /api/v1/users/-/friends/pending?offset=1&limit=5

will return 

    {
      data: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" 
        }, {}
      ],
      status: {
        "offset": 1,
        "limit": 2,
        "next_offset": 3,
        "next_limit": 1,
        "total": 4
      }
    }

* As a user, I would like to accept some of the pending friend request.

    POST /api/v1/users/-/friends/accept

in the body:

    {
      friend_list: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" 
        }
      ]
    }

will return status 202 and empty body. At this point the friends are accepted and they are both friends with each other.

* As a user, I would like to list my existing friends at TidePool

    GET /api/v1/users/-/friends?limit=5&offset=0

will return:

    {
      data: [
        {
          "id": "74",
          "name": "Mary12 Doe",
          "email": "spec_user66@example.com",
          "image": "http://example.com/image12.jpg" }, 
          {}
      ],
      status: {
          "offset": 1,
          "limit": 2,
          "next_offset": 3,
          "next_limit": 1,
          "total": 4
      }
    }
