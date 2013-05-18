class CreateTrackerTypes < ActiveRecord::Migration
  def change
    create_table :tracker_types do |t|
      t.string    :name
      t.boolean   :isCalculated
      
          
      t.timestamps
    end
  end
end
