class CreateEmotionFactorRecommendations < ActiveRecord::Migration
  def change
    create_table :emotion_factor_recommendations do |t|
      t.string :name, :null => false
      t.string :recommendations_per_percentile, :array => true

      t.timestamps
    end

    add_index :emotion_factor_recommendations, :name
  end
end
