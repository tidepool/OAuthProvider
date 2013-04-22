require 'json'

class DoorkeeperSeed
  include SeedsHelper

  def create_seed
    @app = Doorkeeper::Application.where('name = ?', 'tidepool_client_dev').first_or_create do |app|
      app.name = 'tidepool_client_dev'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save!
    app_secrets_dev_path = Rails.root.join('app_secrets_dev.json')
    File.open(app_secrets_dev_path, 'w+') do |file|
      secrets = { :app_id => @app.uid, :app_secret => @app.secret }
      file.write secrets.to_json
    end
  end
end