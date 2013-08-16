class CreateReactionTimeDescriptions < ActiveRecord::Migration
  def change
    create_table :reaction_time_descriptions do |t|
      t.string  :big5_dimension, null: false
      t.string  :speed_archetype, null: false
      t.text    :description
      t.text    :bullet_description
      t.string  :display_id

      t.timestamps
    end

    add_index :reaction_time_descriptions, :big5_dimension
    add_index :reaction_time_descriptions, :speed_archetype
  end
end
