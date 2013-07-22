class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :data_sources
    drop_table :data_source_settings
    drop_table :data_sources_tracker_types
    drop_table :tracker_settings
    drop_table :tracker_types
    drop_table :trackers
    drop_table :adjective_circles
    drop_table :elements
  end
end
