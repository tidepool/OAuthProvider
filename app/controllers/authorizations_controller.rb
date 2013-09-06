class AuthorizationsController < Doorkeeper::AuthorizationsController
  def new
    # Overriding the default implementation:

    if pre_auth.authorizable?
      if Doorkeeper::AccessToken.matching_token_for(pre_auth.client, current_resource_owner.id, pre_auth.scopes) || skip_authorization?
        auth = authorization.authorize

        # The redirect URL that is passed here is created with # instead of ? for 
        # separating query params. 
        # The below will redirect to AuthenticationsController.client_redirect 
        # Below HACK allows client redirect to access the parameters which contains the
        # access_token created by Doorkeeper.
        # TODO: Why does Doorkeeper generate a redirect uri with '#', instead of '?' ?
        uri = auth.redirect_uri.sub!('#', '?')
        redirect_to uri
      else
        render :new
      end
    else
      render :error
    end
  end


  def create
    # Overriding the default implementation:
    # In the default implementation the Token does not have a method
    # called :redirectable, so we need to check to make sure this is checked?
    
    auth = authorization.authorize
    if auth.respond_to?('token')
      user_id = auth.token.resource_owner_id
      user = User.where(id: user_id).first
      if user 
        # user_output = UserSerializer.new(user).as_json
        user_output = UserNewSerializer.new(user).as_json
        output = auth.body.merge(user_output)
      else
        output = auth.body
      end
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