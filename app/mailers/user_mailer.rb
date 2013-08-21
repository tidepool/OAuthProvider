class UserMailer < ActionMailer::Base
  default from: "tidepool@tidepool.co"

  def welcome_email(options)
    user_id = options[:user_id] || options["user_id"]
    @user = User.find(user_id)
    @url = 'https://alpha.tidepool.co'
    mail(to: @user.email, subject: 'Welcome to Tidepool')
  end
end
