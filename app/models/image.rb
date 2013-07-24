# == Schema Information
#
# Table name: images
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  elements      :text
#  primary_color :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Image < ActiveRecord::Base
end
