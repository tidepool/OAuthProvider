# == Schema Information
#
# Table name: emotion_descriptions
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  title         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  friendly_name :string(255)
#  description   :text
#

class EmotionDescription < ActiveRecord::Base
end
