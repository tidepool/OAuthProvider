class FacebookRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?

    set_if_empty(:name, auth_hash.info.name)
    set_if_empty(:email, auth_hash.info.email)
    set_if_empty(:city, auth_hash.info.location)
    set_if_empty(:image, auth_hash.info.image)
    if auth_hash.extra && auth_hash.extra.raw_info 
      set_if_empty(:gender, auth_hash.extra.raw_info.gender)
      set_if_empty(:timezone, auth_hash.extra.raw_info.timezone)
    end
  end
end