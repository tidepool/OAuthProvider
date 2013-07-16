class AddAnalysisVersionToResults < ActiveRecord::Migration
  def change
    add_column :results, :analysis_version, :string

    add_index :results, :time_played
  end
end
