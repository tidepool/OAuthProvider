class AddTimezoneOffsetToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :timezone_offset, :integer
  end
end
