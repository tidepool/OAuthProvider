# == Schema Information
#
# Table name: recommendations
#
#  id             :integer          not null, primary key
#  big5_dimension :string(255)      not null
#  link_type      :string(255)
#  icon_url       :string(255)
#  sentence       :string(255)
#  link_title     :string(255)
#  link           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  display_id     :string(255)
#

class Recommendation < ActiveRecord::Base
  
end
