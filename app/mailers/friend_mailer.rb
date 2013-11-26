class FriendMailer < ActionMailer::Base
  default from: "tidepool@tidepool.co"

  def friend_request_email(options)
    @user, @friend = user_and_friend(options)
    return if @user.nil? || @friend.nil?

    # @url = 'https://itunes.apple.com/us/app/tidepool/id691052387'
    mail(to: @user.email, subject: "Let's connect on TidePool!")
  end

  def friend_accept_email(options)
    @user, @friend = user_and_friend(options)
    return if @user.nil? || @friend.nil?

    mail(to: @user.email, subject: "#{@friend.calculated_name} accepted your friendship request!")    
  end

  private
  def user_and_friend(options)
    user_id = options[:user_id] || options["user_id"]
    friend_id = options[:friend_id] || options["friend_id"]
    User.where(id: [user_id, friend_id]).to_a
  end
end 