class ChangeEmotionDescriptionColumn < ActiveRecord::Migration
  def change
    remove_column :emotion_descriptions, :description
    add_column :emotion_descriptions, :description, :text
  end
end
