class CreateAssessments < ActiveRecord::Migration
  def change
    create_table :assessments do |t|
      t.date     :date_taken
      t.string   :score
      t.integer  :definition_id
      t.integer  :user_id
      t.text     :event_log
      t.text     :intermediate_results
      t.text     :stages
      t.boolean  :results_ready
      t.integer  :profile_description_id
      t.text     :aggregate_results
      t.string   :big5_dimension
      t.string   :holland6_dimension
      t.string   :emo8_dimension
      t.integer  :stage_completed

      t.timestamps
    end
  end
end
