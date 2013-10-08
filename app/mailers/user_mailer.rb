class UserMailer < ActionMailer::Base
  default from: "vnalamothu@tidepool.co"

  def welcome_email(options)
    user_id = options[:user_id] || options["user_id"]
    @user = User.find(user_id)
    @url = 'http://tidepool.co'
    mail(to: @user.email, subject: 'Welcome to Tidepool')
  end

  def password_reset_email(options)
    user_id = options[:user_id] || options["user_id"]
    @temp_password = options[:temp_password] || options["temp_password"]
    @user = User.find(user_id)
    @url = 'http://tidepool.co'
    mail(to: @user.email, subject: 'Password reset request')
  end

  def friend_invite_email(options)
    user_id = options[:user_id] || options["user_id"]
    friend_email = options[:friend_email] || options["friend_email"]
    @user = User.find(user_id)
    @url = 'https://itunes.apple.com/us/app/tidepool/id691052387'
    mail(from: @user.email, to: friend_email, subject: "Join me at Tidepool!")
  end
end
