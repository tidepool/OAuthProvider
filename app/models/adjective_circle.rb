class AdjectiveCircle < ActiveRecord::Base
  attr_accessible :distance_mean, :distance_sd, :distance_weight, :maps_to, :name_pair, :overlap_mean, :overlap_sd, :overlap_weight, :size_mean, :size_sd, :size_weight, :version
end
