require 'blitz'
require 'pp'
require File.expand_path('../../blitz/create_user.rb', __FILE__)

# User Id: 1561
# email :pp@kk.com
# pass: 12345678
# token: cbe52a989f38125da0c2df5bc3c13c7bc0dbbe381c3e940c4bcae3997eb638c9
namespace :loadtests do 
  task :create_guest, [:test_type] => :environment do |t, args|
    test_type = args[:test_type]
    binding.pry
    test = {
      "steps" => [
        {
          "request" => "POST",
          "headers" => ["Content-Type: application/json"],
          "content" => {
            "data" => ["{\"guest\":true}"]
            },
          "url" => "https://tide-dev.herokuapp.com/api/v1/users.json"
        }
      ],
      "region" => "california"      
    }
    sprint = Blitz::Curl::Sprint.new(test)
    # sprint = Blitz::Curl.parse("-r california -X POST -H 'Content-Type: application/json' -d '{\"guest\":true}' https://tide-dev.herokuapp.com/api/v1/users.json")
    result = sprint.execute
    pp :duration => result.duration

    content = JSON.parse result.steps[0].response.content
    pp :response => content

    # Or a Rush
    # rush = Blitz::Curl.parse('-r california -p 10-50:30 www.example.com')
    # rush.execute do |partial|
    #     pp [ partial.region, partial.timeline.last.hits ]
    # end
  end

  task :create_game, [:test_type] => :environment do |t, args|
    test_type = args[:test_type]
    test = {
      "steps" => [
        {
          "timeout" => 2000,
          "request" => "POST",
          "headers" => ["Content-Type: application/json",
            "Authorization: Bearer cbe52a989f38125da0c2df5bc3c13c7bc0dbbe381c3e940c4bcae3997eb638c9"
            ],
          "content" => {
            "data" => ["{\"def_id\":\"snoozer\"}"]
            },
          "url" => "https://tide-dev.herokuapp.com/api/v1/users/-/games.json"
        }
      ],
      "region" => "california"      
    }
    if test_type == "rush"
      test["pattern"] = {
        "iterations" => 1,
        "intervals" => [
          {
            "iterations" => 1,
            "start" => 10,
            "end" => 250,
            "duration" => 60
          }
        ]
      }
      binding.pry
      rush = Blitz::Curl::Rush.new(test)
      rush.execute do |partial|
        pp [ partial.region, partial.timeline.last.hits ]
      end
    else      
      sprint = Blitz::Curl::Sprint.new(test)
      result = sprint.execute
      pp :duration => result.duration

      content = JSON.parse result.steps[0].response.content
      pp :response => content
    end
  end

  task :call_for_results, [:test_type] => :environment do |t, args|
    test = {
      "steps" => [
        {
          "request" => "POST",
          "headers" => ["Content-Type: application/json",
            "Authorization: Bearer cbe52a989f38125da0c2df5bc3c13c7bc0dbbe381c3e940c4bcae3997eb638c9"
            ],
          "content" => {
            "data" => ["{\"def_id\":\"snoozer\"}"]
            },
          "url" => "https://tide-dev.herokuapp.com/api/v1/users/-/games.json"
        }
      ],
      "region" => "california"      
    }
    sprint = Blitz::Curl::Sprint.new(test)
    result = sprint.execute
    binding.pry
    pp :duration => result.duration
    content = JSON.parse result.steps[0].response.content
    game_id = content["data"]["id"]
    data = []
    events = load_event_fixtures('realdata_snoozer.json')
    data << "{\"event_log\":#{events.to_s} }"
    test['steps'][0]['content']['data'] = data
    test['steps'][0]['url'] = "https://tide-dev.herokuapp.com/api/v1/users/-/games/#{game_id}/event_log.json"
    test['steps'][0]['request'] = 'PUT'
    sprint = Blitz::Curl::Sprint.new(test)
    result = sprint.execute
    pp :duration => result.duration
    sleep(1)
    test['steps'][0]['content']['data'] = []
    test['steps'][0]['url'] = "https://tide-dev.herokuapp.com/api/v1/users/-/games/#{game_id}/results.json"
    test['steps'][0]['request'] = 'GET'
    sprint = Blitz::Curl::Sprint.new(test)
    result = sprint.execute
    pp :duration => result.duration
    content = JSON.parse result.steps[0].response.content
    pp :response => content
  end

  task :trigger_results, [:test_type] => :environment do |t, args|
    test_type = args[:test_type]
    test = {
      "steps" => [
        {
          "request" => "GET",
          "headers" => ["Content-Type: application/json",
            "Authorization: Bearer cbe52a989f38125da0c2df5bc3c13c7bc0dbbe381c3e940c4bcae3997eb638c9"
            ],
          "content" => {
            "data" => []
            },
          "url" => "https://tide-dev.herokuapp.com/api/v1/users/-/games/\#{gameid}/results.json"
        }
      ],
      "region" => "california"      
    }
    if test_type == "rush"
      test["steps"][0]["variables"] = {
        "gameid" => {
          "type" => "list",
          "entries" => (3437..3637).to_a | (3642..3693).to_a
        }
      }
      binding.pry
      run_rush(test, 10, 250, 60)
    end
  end

  def load_event_fixtures(filename) 
    events_json = IO.read(File.expand_path("../../analyze/spec/fixtures/#{filename}", __FILE__))
  end

  def run_rush(test, start_users, end_users, duration)
    test["pattern"] = {
      "iterations" => 1,
      "intervals" => [
        {
          "iterations" => 1,
          "start" => start_users,
          "end" => end_users,
          "duration" => duration
        }
      ]
    }
    rush = Blitz::Curl::Rush.new(test)
    rush.execute do |partial|
      pp [ partial.region, partial.timeline.last.hits ]
    end
  end
end