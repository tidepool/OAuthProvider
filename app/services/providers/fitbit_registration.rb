class FitbitRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?
    set_if_empty(:name, auth_hash.info.full_name)
    set_if_empty(:display_name, auth_hash.info.display_name)

    set_gender(auth_hash.info.gender)
    set_if_empty(:city, auth_hash.info.city)
    set_if_empty(:state, auth_hash.info.state)
    set_if_empty(:country, auth_hash.info.country)
    set_dob(auth_hash.info.dob)
    set_if_empty(:timezone, auth_hash.info.timezone)
    set_if_empty(:locale, auth_hash.info.locale)

    if auth_hash.extra && auth_hash.extra.raw_info && auth_hash.extra.raw_info.user
      set_if_empty(:image, auth_hash.extra.raw_info.user.avatar)
    end
  end
end
