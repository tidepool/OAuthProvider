# == Schema Information
#
# Table name: emotion_factor_recommendations
#
#  id                             :integer          not null, primary key
#  name                           :string(255)      not null
#  recommendations_per_percentile :string(255)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class EmotionFactorRecommendation < ActiveRecord::Base
end
