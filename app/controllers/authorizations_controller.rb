class AuthorizationsController < Doorkeeper::AuthorizationsController
  # https://github.com/plataformatec/devise/wiki/How-To%3a-Create-a-guest-user

  def create
    # Overriding the default implementation:
    # In the default implementation the Token does not have a method
    # called :redirectable, so we need to check to make sure this is checked?

    auth = authorization.authorize

    if auth.class.method_defined?(:redirectable) && auth.redirectable?
      redirect_to auth.redirect_uri
    else
      render :json => auth.body, :status => auth.status
    end
  end

  # if user is logged in, return current_user, else return guest_user
  # def current_or_guest_user
  #   if current_user
  #     if session[:guest_user_id]
  #       logging_in
  #       guest_user.destroy
  #       session[:guest_user_id] = nil
  #     end
  #     current_user
  #   else
  #     guest_user
  #   end
  # end

  # # find guest_user object associated with the current session,
  # # creating one as needed
  # def guest_user
  #   # Cache the value the first time it's gotten.
  #   @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  # rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
  #    session[:guest_user_id] = nil
  #    guest_user
  # end

  # private

  # # called (once) when the user logs in, insert any code your application needs
  # # to hand off from guest_user to current_user.
  # def logging_in
  #   # For example:
  #   # guest_comments = guest_user.comments.all
  #   # guest_comments.each do |comment|
  #     # comment.user_id = current_user.id
  #     # comment.save!
  #   # end
  # end

  # def current_user 
  #   if session[:user_id]
  #     @current_user ||= User.find(session[:user_id])
  #   else
  #     @current_user = nil
  #   end
  # end

  # def create_guest_user
  #   u = User.create(:email => "guest_#{Time.now.to_i}#{rand(99)}@example.com")
  #   u.guest = true
  #   u.save!(:validate => false)
  #   session[:guest_user_id] = u.id
  #   u
  # end
end