class Element < ActiveRecord::Base
  attr_accessible :mean, :name, :standard_deviation, :version, :weight_agreeableness, :weight_conscientiousness, :weight_extraversion, :weight_neuroticism, :weight_openness
end
