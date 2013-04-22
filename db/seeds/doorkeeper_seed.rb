require 'json'
require 'dotenv'

class DoorkeeperSeed
  include SeedsHelper

  def create_seed
    Dotenv.load
    @app = Doorkeeper::Application.where('name = ?', 'tidepool_client_dev').first_or_create do |app|
      app.name = 'tidepool_client_dev'
      app.redirect_uri = "#{ENV['OAUTH_REDIRECT']}"
    end
    @app.save!
    app_secrets_dev_path = Rails.root.join('app_secrets_dev.js')
    File.open(app_secrets_dev_path, 'w+') do |file|
      # Generate an AMD wrapped app.config file:
      output = "define([], function(){\n"
      output += "var appConfig = {\n"
      output += " appId: '#{@app.uid}', \n"
      output += " appSecret: '#{@app.secret}', \n"
      output += " apiServer: '#{ENV['API_SERVER']}' \n"
      output += "}; \n"
      output += "return appConfig;\n"
      output += "});"
      file.write output
    end
  end
end