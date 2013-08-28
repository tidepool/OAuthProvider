class AddRemoveColumnsForAggregateResults < ActiveRecord::Migration
  def change
    remove_index :aggregate_results, :high_score
    remove_column :aggregate_results, :high_score
    add_column :aggregate_results, :high_scores, :hstore
  end
end
