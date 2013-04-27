module FacebookPopulate
  def populate_from_facebook(auth, authentication)
    set_if_empty(:name, auth.info.name, authentication)
    set_if_empty(:email, auth.info.email, authentication)
    set_if_empty(:city, auth.info.location, authentication)
    set_if_empty(:image, auth.info.image, authentication)
    set_if_empty(:gender, auth.extra.raw_info.gender, authentication)
    set_if_empty(:timezone, auth.extra.raw_info.timezone, authentication)
  end
end