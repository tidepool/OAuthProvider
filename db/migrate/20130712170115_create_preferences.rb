class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :user_id
      t.string :type
      t.hstore :data

      t.timestamps
    end
  end
end
