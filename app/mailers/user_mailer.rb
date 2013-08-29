class UserMailer < ActionMailer::Base
  default from: "tidepool@tidepool.co"

  def welcome_email(options)
    user_id = options[:user_id] || options["user_id"]
    @user = User.find(user_id)
    @url = 'https://alpha.tidepool.co'
    mail(to: @user.email, subject: 'Welcome to Tidepool')
  end

  def password_reset_email(options)
    user_id = options[:user_id] || options["user_id"]
    @temp_password = options[:temp_password] || options["temp_password"]
    @user = User.find(user_id)
    @url = 'https://alpha.tidepool.co'
    mail(to: @user.email, subject: 'Password reset request')
  end
end
