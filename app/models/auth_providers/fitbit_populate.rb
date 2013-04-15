module FitbitPopulate
  def populate_from_fitbit(auth_hash, authentication)
    set_if_empty(:name, auth.info.full_name, authentication)
    set_if_empty(:display_name, auth.info.display_name, authentication)
    set_if_empty(:gender, auth.info.gender, authentication)
    set_if_empty(:city, auth.info.city, authentication)
    set_if_empty(:state, auth.info.state, authentication)
    set_if_empty(:country, auth.info.state, authentication)
    set_if_empty(:date_of_birth, auth.info.dob, authentication)
    set_if_empty(:timezone, auth.info.timezone, authentication)
    set_if_empty(:locale, auth.info.locale, authentication)
    authentications.member_since = auth.info.member_since
  end
end