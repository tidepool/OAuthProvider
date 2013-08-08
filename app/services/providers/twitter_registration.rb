class TwitterRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?
    set_if_empty(:name, auth_hash.info.name)
    set_if_empty(:display_name, auth_hash.info.nickname)
    set_if_empty(:city, auth_hash.info.location)
    set_if_empty(:image, auth_hash.info.image)
    set_if_empty(:description, auth_hash.info.description)
  end
end