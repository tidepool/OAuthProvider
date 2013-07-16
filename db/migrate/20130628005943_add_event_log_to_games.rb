class AddEventLogToGames < ActiveRecord::Migration
  def change
    add_column :games, :event_log, :text
  end
end
