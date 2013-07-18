class Authentication < ActiveRecord::Base
  belongs_to :user
  
  def self.find_by_provider_and_user(provider, user) 
    @authentications ||= Authentication.where(user_id: user.id).all
    found = nil
    @authentications.each do |authentication|
      if authentication.provider == provider
        found = authentication 
        break
      end
    end
    found
  end
end
