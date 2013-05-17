class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.datetime    :date_entered
      t.

      t.timestamps
    end
  end
end
