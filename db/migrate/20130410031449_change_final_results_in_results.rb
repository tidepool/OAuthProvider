class ChangeFinalResultsInResults < ActiveRecord::Migration
  def change
    remove_column :results, :final_results
    add_column :results, :aggregate_results, :text
  end
end
