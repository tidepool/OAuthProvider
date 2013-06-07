require 'json'
require 'dotenv'

class DoorkeeperSeed
  include SeedsHelper

  def create_seed
    Dotenv.load
    if Rails.env.development? || Rails.env.test?
      @app = Doorkeeper::Application.where('name = ?', 'tidepool_client_dev').first_or_create do |app|
        app.name = 'tidepool_client_dev'
        app.redirect_uri = "#{ENV['OAUTH_REDIRECT']}"
      end
      app_secrets_dev_path = Rails.root.join('.client_env')
      File.open(app_secrets_dev_path, 'w+') do |file|
        # Generate an AMD wrapped app.config file:
        output = "DEV_APISERVER=#{ENV['API_SERVER']}\n"
        output += "DEV_APPSECRET=#{@app.secret}\n"
        output += "DEV_APPID=#{@app.uid}"
        file.write output
      end        
    elsif Rails.env.production?
      @app = Doorkeeper::Application.where('name = ?', 'tidepool_client_prod').first_or_create do |app|
        app.name = 'tidepool_client_prod'
        app.redirect_uri = "#{ENV['OAUTH_REDIRECT']}"
      end
    end
    @app.save!
  end
end