class AddStatusToAssessment < ActiveRecord::Migration
  def change
    add_column :assessments, :status, :string
  end
end
