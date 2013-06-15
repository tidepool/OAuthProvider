class RemoveResultsReadyFromGame < ActiveRecord::Migration
  def change
    remove_column :games, :results_ready, :boolean
  end
end
