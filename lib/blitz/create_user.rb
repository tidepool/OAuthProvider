require 'blitz'
require 'pp'
require 'pry'

def server_endpoint
  # "https://tide-dev.herokuapp.com"
  "https://api.tidepool.co"  
end

def user_token
  # "cbe52a989f38125da0c2df5bc3c13c7bc0dbbe381c3e940c4bcae3997eb638c9"  # Tide-dev
  "f2c298e0f99099166013e7796b5419b1546d03ba7ff499444fc61f9f0ff8e389"  # Production
end

def setup_test
  test = {
    "steps" => [
      {
        "timeout" => 2000,
        "request" => "POST",
        "headers" => ["Content-Type: application/json",
          "Authorization: Bearer #{user_token}"
          ],
        "content" => {
          "data" => ["{\"def_id\":\"snoozer\"}"]
          },
        "url" => "#{server_endpoint}/api/v1/users/-/games.json"
      }
    ],
    "region" => "california"      
  }
end


def setup_test2
  {
    "steps" => [
      {
        "timeout" => 2000,
        "request" => "GET",
        "headers" => ["Content-Type: application/json",
          "Authorization: Bearer #{user_token}"
          ],
        "content" => {
          "data" => []
          },
        "url" => "#{server_endpoint}/api/v1/users/-/games/\#{gameid}/results.json"
      }
    ],
    "region" => "california"      
  }
end