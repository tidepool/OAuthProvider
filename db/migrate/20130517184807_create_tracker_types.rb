class CreateTrackerTypes < ActiveRecord::Migration
  def change
    create_table :tracker_types do |t|
      t.string    :name
      t.string    :category
      t.boolean   :isCalculated
      t.text      :schema
                
      t.timestamps
    end
  end
end