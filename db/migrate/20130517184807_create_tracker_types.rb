class CreateTrackerTypes < ActiveRecord::Migration
  def change
    create_table :tracker_types do |t|

      t.timestamps
    end
  end
end
