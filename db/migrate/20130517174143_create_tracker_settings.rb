class CreateTrackerSettings < ActiveRecord::Migration
  def change
    create_table :tracker_settings do |t|

      t.timestamps
    end
  end
end
