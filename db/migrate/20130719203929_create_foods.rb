class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
      t.integer :user_id, null: false
      t.date :date_recorded, null: false

      t.hstore :data
      t.hstore :goals

      t.text :details

      t.string :provider 

      t.timestamps
    end

    add_index :foods, :user_id
    add_index :foods, :date_recorded
    add_index :foods, :provider
  end
end
