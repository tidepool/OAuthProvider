class CreateSpeedArchetypeDescriptions < ActiveRecord::Migration
  def change
    create_table :speed_archetype_descriptions do |t|
      t.string  :speed_archetype, null: false
      t.text    :description
      t.string  :display_id

      t.timestamps
    end

    add_index :speed_archetype_descriptions, :speed_archetype
  end
end
