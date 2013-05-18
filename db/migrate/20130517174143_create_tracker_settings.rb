class CreateTrackerSettings < ActiveRecord::Migration
  def change
    create_table :tracker_settings do |t|
      t.integer     :user_id
      t.string      :data_methods, array: true
      t.hstore      :config 
      t.hstore      :privacy_config
      
      t.timestamps
    end
  end
end
