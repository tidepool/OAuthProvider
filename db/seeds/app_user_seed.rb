class AppUserSeed
  include SeedsHelper

  def create_seed
    # Create the admin account for us
    admin = Admin.where('email = ?', 'admin@tidepool.co').first
    if admin.nil?
      admin = Admin.create! :email => 'admin@tidepool.co',
                            :password => ENV['ADMIN_PASS'],
                            :password_confirmation => ENV['ADMIN_PASS']
    
      admin.save!
    end


    # Create the test application and user
    if Rails.env.development? || Rails.env.test?
      user = User.where('email = ?', 'user@example.com').first

      if user.nil?
        user = User.create! :email => 'user@example.com', 
                            :password => 'tidepool', 
                            :password_confirmation => 'tidepool' 
        user.admin = false
        user.save
      end

      user2 = User.where('email = ?', 'user2@example.com').first

      if user2.nil?
        user2 = User.create! :email => 'user2@example.com', 
                            :password => 'tidepool', 
                            :password_confirmation => 'tidepool' 
        user2.admin = false
        user2.save
      end

      admin_user = User.where('email = ?', 'admin@example.com').first

      if admin_user.nil?
        admin_user = User.create! :email => 'admin@example.com', 
                                  :password => 'tidepool', 
                                  :password_confirmation => 'tidepool'
        admin_user.admin = true
        admin_user.save
      end

      app = Doorkeeper::Application.where('name = ?', 'tidepool_test').first_or_create do |app|
        app.name = 'tidepool_test'
        app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      end
      app.save!

      ios_app = Doorkeeper::Application.where('name = ?', 'tidepool_ios').first_or_create do |ios_app|
        ios_app.name = 'tidepool_ios'
        ios_app.redirect_uri = 'http://assessments-front.dev/redirect.html'
      end

      user_int = User.where(email: 'user_int@example.com').first
      if user_int.nil?
        user_int = User.create! :email => 'user_int@example.com', 
                            :password => 'tidepool', 
                            :password_confirmation => 'tidepool' 
        user_int.admin = false
        user_int.save
      end
      token = Doorkeeper::AccessToken.where(resource_owner_id: user_int.id).first

      if token.nil?
        expires_in = 2.years
        token = Doorkeeper::AccessToken.create! :application_id => ios_app.id,
                                                  :use_refresh_token => true,
                                                  :resource_owner_id => user_int.id,
                                                  :expires_in => expires_in
      end

      puts 'Users :'
      puts "email: #{user.email}"
      puts "email: #{user2.email}"
      puts "email: #{admin_user.email}"
      puts 'Application: '
      puts "name: #{app.name}"
      puts "redirect_uri: #{app.redirect_uri}"
      puts "uid: #{app.uid}"
      puts "secret: #{app.secret}"

      puts "iOS APP---------"
      puts "secret: #{ios_app.secret}"
      puts "uid: #{ios_app.uid}"
      puts "token: #{token.token}"
    end
  end
end