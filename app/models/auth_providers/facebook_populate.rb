module FacebookPopulate
  def populate_from_facebook(auth, authentication)
    return if auth.info.nil?
    set_if_empty(:name, auth.info.name, authentication)
    set_if_empty(:email, auth.info.email, authentication)
    set_if_empty(:city, auth.info.location, authentication)
    set_if_empty(:image, auth.info.image, authentication)
    if auth.extra && auth.extra.raw_info 
      set_if_empty(:gender, auth.extra.raw_info.gender, authentication)
      set_if_empty(:timezone, auth.extra.raw_info.timezone, authentication)
    end
  end
end