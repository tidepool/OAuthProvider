class JawboneRegistration < BaseRegistration
  def populate(auth_hash)
    return if auth_hash.nil? || auth_hash.info.nil?
    # Rails.logger.info("Connected to Fitbit: #{auth_hash.info}\n #{auth_hash.extra.raw_info.user}")
    set_if_empty(:name, auth_hash.info.full_name)
    set_if_empty(:display_name, auth_hash.info.display_name)
  end
end