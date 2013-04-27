class ChangeDateTakenType < ActiveRecord::Migration
  def up
   change_column :assessments, :date_taken, :datetime
  end

  def down
   change_column :assessments, :date_taken, :date
  end
end
