class AddFriendlyNameToEmotionDescription < ActiveRecord::Migration
  def change
    add_column :emotion_descriptions, :friendly_name, :string
    remove_column :emotion_descriptions, :icon_url
  end
end
