class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :user_id, null: false
      t.date :date_recorded, null: false

      t.integer :type_id

      t.string :name

      t.hstore :data
      t.hstore :goals

      t.text :daily_breakdown

      t.string :provider 

      t.timestamps
    end

    add_index :activities, :user_id
    add_index :activities, :date_recorded
    add_index :activities, :provider
  end
end
