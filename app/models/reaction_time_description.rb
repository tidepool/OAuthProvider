class ReactionTimeDescription < ActiveRecord::Base
  serialize :bullet_description, JSON

end
