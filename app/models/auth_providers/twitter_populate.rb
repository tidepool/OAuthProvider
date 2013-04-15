module TwitterPopulate
  def populate_from_twitter(auth_hash, authentication)
    set_if_empty(:name, auth.info.name, authentication)
    set_if_empty(:display_name, auth.info.nickname, authentication)
    set_if_empty(:city, auth.info.location, authentication)
    set_if_empty(:image, auth.info.image, authentication)
    set_if_empty(:description, auth.info.description, authentication)
  end
end