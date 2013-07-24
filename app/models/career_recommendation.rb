# == Schema Information
#
# Table name: career_recommendations
#
#  id                     :integer          not null, primary key
#  profile_description_id :integer
#  careers                :string(255)
#  skills                 :string(255)
#  tools                  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

class CareerRecommendation < ActiveRecord::Base
  belongs_to :profile_description

end
