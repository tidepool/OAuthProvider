class ChangeIsDobByAgeToHaveDefaultFalse < ActiveRecord::Migration
  def change
    change_column_default :users, :is_dob_by_age, false
  end
end
