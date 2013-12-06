class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer     :user_id, null: false
      t.string      :os, null: false
      t.string      :os_version
      t.string      :hardware
      t.string      :name
      t.string      :token

      t.timestamps
    end

    add_index :devices, :user_id
  end
end
