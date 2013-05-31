Case 1:
-------
Create a new registered user

      POST api/v1/users/?username=&password=&password_confirmation

Params:
  email - 
  password - 
  password_confirmation -

Returns:


Case 2:
-------
Create a guest user 

      POST api/v1/users/?guest=true

Params:
  guest - true

Returns:
  user: {
    email: guest...@example.com
    guest: true 
  }

Internally:
  * Create a user with a fake random email
  * resource_owner_from_credentials -> if the user is guest does not require a password for authorization

Case 3:
-------
Convert a guest user to a registered user

      PUT/PATCH api/v1/users/:user_id?username=&password=&password_confirmation

Params:
  email - 
  password - 
  password_confirmation -

Returns:
  user: {
    email: registered_email@
    guest: false
  }

Internally:
* The first update to a guest user with email, password & password_confirm will convert the guest to registered user.
* Guest users cannot have any updates to their user account, since technically they don't really have registered accounts to be kept track of by themselves.

Case 4:
-------
Create a new registered user by external authentication

* NO API-only way to do this as it relies on OAuth flows
* Popup a new browser window and navigate the window to:

      GET oauth/authorize
  
Params:
  provider - name of the external provider (E.g. facebook, fitbit, ...)
  client_id - the client_id given from the API server
  redirect_uri - this should redirect back to the client app's handler page. In this case it is redirect.html
  response_type=token - this is fixed and always need to ask for a token

Returns:
  Once the user is authenticated with the provider, the redirect_uri will be called(GET) with a hash of parameters that contain the access_token and expires_in time.
      GET redirect_uri?access_token=&expires_in

Internally:
* resource_owner_authenticator block is called with all the params (Doorkeeper calls current_resource_owner which in turn uses this block to return the user)
  * The block checks if there is a user_id param, if there is then it is redirected from the external authentication flow with a user of user_id, so it finds that user and returns it.
  * If not then it checks if there is a provider (external) specified and it redirects to the external provider for the authentication. At this point there is no way to preserve the params through a query string, so we stash them in the session as such:
    * session[:guest_id] if specified (See Case 5)
    * session[:redirect_after_external] to specify where to redirect back to after external authentication
    * session[:user_id]
* The external authentication (through OmniAuth support, using /auth/:provider) happens.
* If successful the AuthenticationsController::create method is called.
  * It checks if there is an existing user_id in the session (This will be true if adding a new external authentication to a user, see Case 6 for that flow)
  * Otherwise it checks if the authentication already exists in our database. (This will be true if we are simply logging in an existing user through external authentication)
    * If so it will get that existing user and redirect back to the oauth/authorize with that user_id in the paramaters.
  * Otherwise it checks if the session[:guest_id] exists if so that means, we are trying to convert a guest to a registered user (see case 5)
  * Otherwise it is a real first time user so it need to be created fresh. Creates the user populates with data retrieved from external provider.
* We cleanup the session variables and then return back to the oauth/user with the user_id in the parameters.
  * Then the resource_owner_authenticator block finds the user with the user_id and returns.
* Doorkeeper returns the generated tokens back to the redirect_uri


Case 5:
-------
Convert a guest to a registered user by external authentication

* NO API-only way to do this as it relies on OAuth flows
* Popup a new browser window and navigate the window to:

      GET oauth/authorize

Params:
  provider - name of the external provider (E.g. facebook, fitbit, ...)
  client_id - the client_id given from the API server
  redirect_uri - this should redirect back to the client app's handler page. In this case it is redirect.html
  response_type=token - this is fixed and always need to ask for a token
  user_id - The guest users' id to be converted to registered user.
  action - "convert_guest"

Returns:
  

Internally:




Case 6:
-------
Add new external authentication to a registered user






