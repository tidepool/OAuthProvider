class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.string  :big5_dimension,  :null => false
      t.string  :link_type
      t.string  :icon_url
      t.string  :sentence
      t.string  :link_title
      t.string  :link

      t.timestamps
    end

    add_index :recommendations, :big5_dimension 
  end
end
