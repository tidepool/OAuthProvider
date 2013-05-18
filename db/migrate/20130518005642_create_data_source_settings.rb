class CreateDataSourceSettings < ActiveRecord::Migration
  def change
    create_table :data_source_settings do |t|
      t.references    :user
      t.references    :data_source
      t.string        :auth_token
      t.datetime      :expires

      t.timestamps
    end
  end
end
