module AppConnections
  def find_or_create_app
    @app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
      app.name = 'tidepool_test'
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    end
    @app.save!
  end

  def get_conn(user = nil, password = '12345678')
    if user.nil?
      anon_client = Faraday.new do |f|
        f.request :url_encoded
        f.adapter :rack, Rails.application
      end      
    else
      client = OAuth2::Client.new(@app.uid, @app.secret, raise_errors: false) do |b|
        b.request :url_encoded
        b.adapter :rack, Rails.application
      end   
      client.password.get_token(user.email, password)
    end
  end
end