require 'blitz'
require 'pp'
require File.expand_path('../../blitz/create_user.rb', __FILE__)

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
end