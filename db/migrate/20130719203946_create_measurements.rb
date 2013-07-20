class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.integer :user_id, null: false
      t.date :date_recorded, null: false

      t.hstore :data
      t.hstore :goals

      t.text :details

      t.string :provider 
      t.timestamps
    end

    add_index :measurements, :user_id
    add_index :measurements, :date_recorded
    add_index :measurements, :provider
  end
end
