class AuthorizationsController < Doorkeeper::AuthorizationsController
  def create
    # Overriding the default implementation:
    # In the default implementation the Token does not have a method
    # called :redirectable, so we need to check to make sure this is checked?

    auth = authorization.authorize
    if auth.class.method_defined?(:redirectable) && auth.redirectable?
      puts("REDIRECT URI !!!!! => #{auth.redirect_uri}")
      redirect_to auth.redirect_uri
    else
      render :json => auth.body, :status => auth.status
    end
  end
end