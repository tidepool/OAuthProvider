class CreateSocialGameDefinitions < ActiveRecord::Migration
  def change
    create_table :social_game_definitions do |t|
      t.string  :unique_name
      t.hstore  :game_definitions

      t.timestamps
    end
  end
end
