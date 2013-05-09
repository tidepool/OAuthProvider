Pre-requisites:
---------------

* Use rbenv for ruby version management:

        brew update
        brew install rbenv
        brew install ruby-build
  
  DO NOT Forget to add this to your .zshrc or .profile (depending on your shell)
  
        if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
  
  Then install and switch to the LATEST_RUBY version (currently at 2.0.0-p0)

        rbenv install LATEST_RUBY
        rbenv global LATEST_RUBY

  (Make sure you are on latest Ruby before continuing)

* Install globally:

        gem install bundler
        gem install foreman

* Install Postgres:
  
    Easiest way to install Postgres: http://postgresapp.com/

* Install redis:

        brew install redis

  and run it: (default options)

        redis-server


Installation:
-------------

* Install the dependencies: (all gems will be installed under that vendor/bundle folder.)

        bundle install --path vendor/bundle

* Start up the Postgres database server

* Set up the .env file (Create a .env file in your root Rails folder with the following)

        RACK_ENV=development
        API_SERVER=http://api-server.dev
        OAUTH_REDIRECT=http://assessments-front.dev/
        FACEBOOK_KEY=
        FACEBOOK_SECRET=
        FITBIT_KEY=
        FITBIT_SECRET=
        TWITTER_KEY=
        TWITTER_SECRET=

* Set up the database

        bundle exec rake db:setup
        bundle exec rake db:migrate
        bundle exec rake db:seed

* Setting up POW (http://pow.cx/): 
  (We are just using POW as a proxy/DNS server, it is not a web server.)

        curl get.pow.cx | sh
        echo 7004 > ~/.pow/api-server

Start the server now:

        foreman start

