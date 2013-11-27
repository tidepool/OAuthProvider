class CreateHighfives < ActiveRecord::Migration
  def change
    create_table :highfives do |t|
      t.integer   :user_id,    null: false
      t.integer   :activity_record_id

      t.timestamps
    end
  end
end
