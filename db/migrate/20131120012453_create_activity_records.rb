class CreateActivityRecords < ActiveRecord::Migration
  def change
    create_table :activity_records do |t|
      t.integer   :user_id,       null: false
      t.datetime  :performed_at,  null: false  
      t.text      :raw_data
      t.string    :type

      t.timestamps
    end

    add_index   :activity_records, :user_id
    add_index   :activity_records, :performed_at
  end
end
