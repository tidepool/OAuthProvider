# Devices 

## API

### Devices

* Get a list of devices for a user


```    GET "api/v1/users/-/devices"  ```

will return:

    {
          :data => [
            {
                        :id => 2,
                   :user_id => 131,
                      :name => "My Device #2",
                        :os => "ios",
                :os_version => "6.2",
                     :token => "TOKEN2468",
                  :hardware => "Hardware #2"
            },
            {
                        :id => 1,
                   :user_id => 131,
                      :name => "My Device #1",
                        :os => "ios",
                :os_version => "6.1",
                     :token => "TOKEN1234",
                  :hardware => "Hardware #1"
            }
        ],
        :status => {}
    }

* Create a new device for a user: 
    
``` POST "api/v1/users/-/devices" ```

with (Note that ```os``` field is required)

    {
      device: {
        os: "ios",
        os_version: "7.1",
        token: "12212313"
      }
    }

will return:

    {
      :data => {
                :id => 2,
           :user_id => 131,
                :os => "ios",
        :os_version => "7.1",
             :token => "TOKEN2468",
      },
      :status => {}
    }

* Change the device data:

```  PUT "api/v1/users/-/devices/55" ```

where ```55``` is the ```device_id```

with 

    {
      device: {
        name: "New device name"
      }
    }

will return:

    {
      :data => {
                            :id => 18,
                       :user_id => 213,
                            :os => "ios",
                          :text => "New device name",
      },
      :status => {}
    }


* Delete a device:

```  DELETE "api/v1/users/-/devices/55" ```

where ```55``` is the ```device_id```