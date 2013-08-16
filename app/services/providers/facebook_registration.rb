class FacebookRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?

    set_if_empty(:name, auth_hash.info.name)
    set_if_empty(:email, auth_hash.info.email)
    set_if_empty(:image, auth_hash.info.image)
    set_dob(auth_hash.info.dob)
    set_location(auth_hash.info.location)
    set_gender(auth_hash.info.gender)

    if auth_hash.extra && auth_hash.extra.raw_info 
      set_if_empty(:gender, auth_hash.extra.raw_info.gender)
      set_if_empty(:timezone, auth_hash.extra.raw_info.timezone)
      set_dob(auth_hash.extra.raw_info.dob)
    end
  end

end