class CreateCareerRecommendations < ActiveRecord::Migration
  def change
    create_table :career_recommendations do |t|
      t.integer :profile_description_id
      t.string :careers, array: true
      t.string :skills, array: true
      t.string :tools, array: true

      t.timestamps
    end
  end
end
