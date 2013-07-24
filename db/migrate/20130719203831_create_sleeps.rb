class CreateSleeps < ActiveRecord::Migration
  def change
    create_table :sleeps do |t|
      t.integer :user_id, null: false
      t.date :date_recorded, null: false

      t.hstore :data
      t.hstore :goals

      t.text :sleep_activity

      t.string :provider 

      t.timestamps
    end

    add_index :sleeps, :user_id
    add_index :sleeps, :date_recorded
    add_index :sleeps, :provider
  end
end
