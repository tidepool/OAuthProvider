module FitbitPopulate
  def populate_from_fitbit(auth, authentication)
    set_if_empty(:name, auth.info.full_name, authentication)
    set_if_empty(:display_name, auth.info.display_name, authentication)

    # TODO: This is not really email, but Fitbit does not give any email
    set_if_empty(:email, auth.info.display_name, authentication)

    set_if_empty(:gender, auth.info.gender, authentication)
    set_if_empty(:city, auth.info.city, authentication)
    set_if_empty(:state, auth.info.state, authentication)
    set_if_empty(:country, auth.info.state, authentication)
    if self.date_of_birth.nil?
      self.date_of_birth = auth.info.dob
      authentication.date_of_birth = auth.info.dob      
    end
    # set_if_empty(:date_of_birth, auth.info.dob, authentication)
    set_if_empty(:timezone, auth.info.timezone, authentication)
    set_if_empty(:locale, auth.info.locale, authentication)
    set_if_empty(:image, auth.extra.raw_info.user.avatar, authentication)
    # set_if_empty(:height, auth.extra.raw_info.user.height, authentication)
    # set_if_empty(:height_unit, auth.extra.raw_info.user.heightUnit, authentication)
    # set_if_empty(:weight, auth.extra.raw_info.user.weight, authentication)   
    # set_if_empty(:weight_unit, auth.extra.raw_info.user.weightUnit, authentication) 
    authentication.member_since = auth.info.member_since
  end
end