class AddTimeColumnsToResults < ActiveRecord::Migration
  def change
    add_column :results, :time_played, :datetime
    add_column :results, :time_calculated, :datetime
  end
end
