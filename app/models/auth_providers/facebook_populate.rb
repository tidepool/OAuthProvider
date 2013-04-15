module FacebookPopulate
  def populate_from_facebook(auth_hash, authentication)
    set_if_empty(:name, auth.info.name, authentication)
    set_if_empty(:email, auth.info.email, authentication)
    set_if_empty(:city, auth.info.location, authentication)
    set_if_empty(:image, auth.info.image, authentication)
  end
end