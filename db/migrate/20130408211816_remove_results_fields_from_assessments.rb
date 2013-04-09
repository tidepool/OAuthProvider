class RemoveResultsFieldsFromAssessments < ActiveRecord::Migration
  def change 
    remove_column :assessments, :intermediate_results
    remove_column :assessments, :aggregate_results
    remove_column :assessments, :big5_dimension
    remove_column :assessments, :holland6_dimension
    remove_column :assessments, :emo8_dimension
    remove_column :assessments, :profile_description_id
    remove_column :assessments, :score
    remove_column :assessments, :event_log
  end
end
