# == Schema Information
#
# Table name: profile_descriptions
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  description        :text
#  one_liner          :string(255)
#  bullet_description :text
#  big5_dimension     :string(255)
#  holland6_dimension :string(255)
#  code               :string(255)
#  logo_url           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  display_id         :string(255)
#

class ProfileDescription < ActiveRecord::Base
  serialize :bullet_description, JSON

  # has_many :users
  # has_many :results
  has_many :personalities
end
