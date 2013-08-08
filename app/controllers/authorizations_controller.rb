class AuthorizationsController < Doorkeeper::AuthorizationsController
  def create
    # Overriding the default implementation:
    # In the default implementation the Token does not have a method
    # called :redirectable, so we need to check to make sure this is checked?
    
    auth = authorization.authorize
    user_id = auth.token.resource_owner_id
    user = User.where(id: user_id).first
    if user 
      user_output = UserSerializer.new(user).as_json
      output = auth.body.merge(user_output)
    else
      output = auth.body
    end

    if auth.class.method_defined?(:redirectable) && auth.redirectable?
      puts("REDIRECT URI !!!!! => #{auth.redirect_uri}")
      redirect_to auth.redirect_uri
    else
      render :json => output, :status => auth.status
    end
  end
end