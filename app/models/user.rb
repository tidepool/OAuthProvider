class User < ActiveRecord::Base
  has_secure_password

  attr_accessible :email, :password, :password_confirmation
  validates_uniqueness_of :email

  belongs_to :profile_description

  def self.find_or_create_from_auth_hash(auth_hash)
    
  end
end
