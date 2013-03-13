class Image < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string   :name
      t.text     :elements
      t.string   :primary_color
                  
      t.timestamps
    end
  end 
end
