class BaseRegistration
  def initialize(user, authentication)
    @user = user
    @authentication = authentication
  end

  def set_if_empty(property, value)
    @authentication[property] = value

    if @user[property].nil? || (@user[property].class == String && @user[property].empty?) || @user.guest
      @user[property] = value
    end
  end
end
