class CreateTrackers < ActiveRecord::Migration
  def change
    create_table :trackers do |t|
      t.integer     :tracker_type_id
      t.references  :user
      t.datetime    :date_started
      t.datetime    :date_ended
      t.hstore      :data
      t.datetime    :date_updated_at
      
      t.timestamps
    end
  end
end
