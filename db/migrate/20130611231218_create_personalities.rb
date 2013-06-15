class CreatePersonalities < ActiveRecord::Migration
  def change
    create_table :personalities do |t|
      t.integer :profile_description
      t.integer :user
      t.integer :game
      t.text :big5_score
      t.text :holland6_score
      t.string :big5_dimension
      t.string :holland6_dimension
      t.string :big5_low
      t.string :big5_high

      t.timestamps
    end
  end
end
