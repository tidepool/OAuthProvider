class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer   :assessment_id, :null => false

      t.text      :event_log
      t.text      :intermediate_results
      t.text      :final_results
      t.text      :scores

      # if the result calculates a profile description, it is saved here
      t.integer   :profile_description_id
      t.timestamps
    end
  end

  add_index :results, :assessment_id, :unique => true
end
