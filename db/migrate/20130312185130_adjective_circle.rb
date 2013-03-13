class AdjectiveCircle < ActiveRecord::Migration
  def change
    create_table :adjective_circles do |t|
      t.string   :name_pair
      t.string   :version
      t.float    :size_weight
      t.float    :size_sd
      t.float    :size_mean
      t.float    :distance_weight
      t.float    :distance_sd
      t.float    :distance_mean
      t.float    :overlap_weight
      t.float    :overlap_sd
      t.float    :overlap_mean
      t.string   :maps_to
      
      t.timestamps
    end
  end 
end
