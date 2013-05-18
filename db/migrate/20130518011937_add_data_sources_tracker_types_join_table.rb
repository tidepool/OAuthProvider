class AddDataSourcesTrackerTypesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :data_sources_tracker_types, :id => false do |t|
      t.references :data_source
      t.references :tracker_type
    end
  end
  
  def self.down
    drop_table :data_sources_tracker_types
  end
end
