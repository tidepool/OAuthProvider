# == Schema Information
#
# Table name: authentications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  provider          :string(255)
#  uid               :string(255)
#  oauth_token       :string(255)
#  oauth_expires_at  :datetime
#  email             :string(255)
#  name              :string(255)
#  display_name      :string(255)
#  description       :string(255)
#  city              :string(255)
#  state             :string(255)
#  country           :string(255)
#  timezone          :string(255)
#  locale            :string(255)
#  image             :string(255)
#  gender            :string(255)
#  date_of_birth     :date
#  member_since      :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  oauth_secret      :string(255)
#  is_activated      :boolean
#  last_accessed     :datetime
#  last_synchronized :hstore
#  profile           :hstore
#  sync_status       :string(255)
#  last_error        :text
#

class Authentication < ActiveRecord::Base
  belongs_to :user
  
  def check_and_reset_credentials(auth_hash)
    if auth_hash && auth_hash.credentials
      self.oauth_token = auth_hash.credentials.token
      self.oauth_secret = auth_hash.credentials.secret
      # oauth_expires_at is deprecated.
    else
      logger.warn("Auth hash does not have credentials info. Provider = #{auth_hash.provider}")
    end
  end

end
