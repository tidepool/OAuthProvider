class CreateEmotionDescriptions < ActiveRecord::Migration
  def change
    create_table :emotion_descriptions do |t|
      t.string :name, :null => false
      t.string :title
      t.string :description
      t.string :icon_url

      t.timestamps
    end

    add_index :emotion_descriptions, :name
  end
end
