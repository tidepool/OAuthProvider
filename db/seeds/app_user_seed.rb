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

      puts 'Users :'
      puts "email: #{user.email}"
      puts "email: #{user2.email}"
      puts "email: #{admin_user.email}"
      puts 'Application: '
      puts "name: #{app.name}"
      puts "redirect_uri: #{app.redirect_uri}"
      puts "uid: #{app.uid}"
      puts "secret: #{app.secret}"
    end
  end
end