# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)      default(""), not null
#  admin           :boolean          default(FALSE), not null
#  guest           :boolean          default(FALSE), not null
#  name            :string(255)
#  display_name    :string(255)
#  description     :string(255)
#  city            :string(255)
#  state           :string(255)
#  country         :string(255)
#  timezone        :string(255)
#  locale          :string(255)
#  image           :string(255)
#  gender          :string(255)
#  date_of_birth   :date
#  handedness      :string(255)
#  orientation     :string(255)
#  education       :string(255)
#  referred_by     :string(255)
#  stats           :hstore
#

class User < ActiveRecord::Base
  has_secure_password validations: false
  
  validates_uniqueness_of :email
  validates_format_of :email, :with => /.+@.+\..+/i
  validates :password, :length => { :minimum => 8 }, :if => :needs_password?, on: :create
  validates_confirmation_of :password

  has_one :personality
  has_many :authentications
  has_many :preorders
  has_many :results
  has_many :aggregate_results
  has_many :preferences
  has_many :activities
  has_one :access_token,  foreign_key: "resource_owner_id", class_name: "Doorkeeper::AccessToken"

  has_many :friendships
  has_many :friends, :through => :friendships
  
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  
  def needs_password?
    guest == false #&& (password.present? || password_confirmation.present?)
  end

  def update_attributes(attributes)
    begin
      self.update_attributes!(attributes)
    rescue Exception => e
      false
    end
  end

  def update_attributes!(attributes)
    self.guest = false # The user is no longer a guest
    super
  end
end
