class BaseRegistration
  def initialize(user, authentication)
    @user = user
    @authentication = authentication
  end

  def set_if_empty(property, value)
    return if value.nil?

    @authentication[property] = value

    if @user[property].nil? || (@user[property].class == String && @user[property].empty?) || @user.guest
      @user[property] = value
    end
  end

  def set_dob(dob)
    return if dob.nil?
    if @user.date_of_birth.nil?
      date_of_birth = Tidepool::TimeHelper.time_from_unknown_format(dob)
      @user.date_of_birth = date_of_birth
      @authentication.date_of_birth = date_of_birth     
    end
  end

  def set_location(location)
    return if location.nil? || location.class != String

    city, state = location.split(',').map { |item| item.strip }
    set_if_empty(:city, city)
    set_if_empty(:state, state)    
  end

  def set_gender(gender)
    return if gender.class != String
    
    set_if_empty(:gender, gender.downcase)
  end
end
