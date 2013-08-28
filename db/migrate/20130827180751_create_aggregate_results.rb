class CreateAggregateResults < ActiveRecord::Migration
  def change
    create_table :aggregate_results do |t|
      t.integer :user_id, null: false
      t.string :type
      t.integer :high_score
      t.text :scores

      t.timestamps
    end

    add_index :aggregate_results, :user_id
    add_index :aggregate_results, :high_score
  end
end
