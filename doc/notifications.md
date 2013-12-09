# Notifications 

## API

### Notifications

* Get a list of notifications for a user (Note that notifications are only kept for 2 weeks)


```    GET "api/v1/users/-/notifications"  ```

will return:

    {
      :data => [
        {
          :message => "Mary liked John new highscore.",
          :is_read => false
        },
        {
          :message => "Mary commented on John new highscore.",
          :is_read => false
        },
        {
          :message => "John is now friends with Mary.",
          :is_read => false
        }],
        :status => {
                 :offset => 0,
                  :limit => 20,
            :next_offset => 0,
             :next_limit => 20,
                  :total => 3
        }
    }

* Clear notifications for a user: (This sets the notification status to "read" for all notifications that are "unread") 
    
``` POST "api/v1/users/-/notifications/clear" ```

will return:

    {
      :data => {},
      :status => {}
    }

