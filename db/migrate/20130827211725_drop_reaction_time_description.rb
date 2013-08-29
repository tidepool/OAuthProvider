class DropReactionTimeDescription < ActiveRecord::Migration
  def change
    remove_index :reaction_time_descriptions, :big5_dimension
    remove_index :reaction_time_descriptions, :speed_archetype

    drop_table :reaction_time_descriptions
  end
end
