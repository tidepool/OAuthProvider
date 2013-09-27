class AddTimeZoneOffsetToResults < ActiveRecord::Migration
  def change
    add_column :results, :timezone_offset, :integer
  end
end
