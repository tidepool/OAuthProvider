class AddDisplayIdToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :display_id, :string
  end
end
