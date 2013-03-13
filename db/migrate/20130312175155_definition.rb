class Definition < ActiveRecord::Migration
  def change
    create_table :definitions do |t|
      t.string   :name
      t.text     :stages
      t.text     :instructions
      t.text     :end_remarks
      t.string   :experiment
      t.string   :icon

      t.timestamps
    end
  end
end
