# Comments & Highfives

## API

### Comments

* Get a list of comments for an activity record:


```    GET "api/v1/feeds/123/comments?offset=0&limit=5"  ```

where ```123``` is the ``` activity_record_id ```

will return:

    {
      :data => [
        {
                            :id => 15,
                       :user_id => 295,
            :activity_record_id => 49,
                          :text => "Awesome comment 15",
                     :user_name => "John Doe",
                    :user_image => "http://example.com/image187.jpg",
                    :updated_at => "2013-11-27T11:34:59.097-08:00"
        },
    ],
    :status => {
             :offset => 0,
              :limit => 5,
        :next_offset => 5,
         :next_limit => 5,
              :total => 15
        }
    }

* Create a new comment for an activity record:
    
``` POST "api/v1/feeds/123/comments" ```

where ```123``` is the ``` activity_record_id ```

with 

    {
      comment: {
        text: "Hello this is a comment"
      }
    }

will return:

    {
      :data => {
                            :id => 18,
                       :user_id => 213,
            :activity_record_id => 45,
                          :text => "Hello this is a comment",
                    :updated_at => "2013-11-27T11:41:39.684-08:00"
      },
      :status => {}
    }

* Change the comment text:

```  PUT "api/v1/comments/55" ```

where ```55``` is the ```comment_id```

with 

    {
      comment: {
        text: "Awesome comment!"
      }
    }

will return:

    {
      :data => {
                            :id => 18,
                       :user_id => 213,
            :activity_record_id => 45,
                          :text => "Awesome comment!",
                    :updated_at => "2013-11-27T11:41:39.684-08:00"
      },
      :status => {}
    }


* Delete a comment:

```  DELETE "api/v1/comments/55" ```

where ```55``` is the ```comment_id```

### Highfives

* Get a list of highfives for an activity record

```    GET "api/v1/feeds/123/highfives?offset=0&limit=5"  ```

where ```123``` is the ``` activity_record_id ```

will return:

    {
      :data => [
        {
                            :id => 15,
                       :user_id => 295,
            :activity_record_id => 49,
                     :user_name => "John Doe",
                    :user_image => "http://example.com/image187.jpg",
                    :updated_at => "2013-11-27T11:34:59.097-08:00"
        },
    ],
    :status => {
             :offset => 0,
              :limit => 5,
        :next_offset => 5,
         :next_limit => 5,
              :total => 15
        }
    }

* Create a new highfive for an activity record:
    
``` POST "api/v1/feeds/123/highfives" ```

where ```123``` is the ``` activity_record_id ```

will return:

    {
      :data => {
                            :id => 18,
                       :user_id => 213,
            :activity_record_id => 45,
                    :updated_at => "2013-11-27T11:41:39.684-08:00"
      },
      :status => {}
    }


* Delete a highfive:

```  DELETE "api/v1/highfives/55" ```

where ```55``` is the ```highfive_id```