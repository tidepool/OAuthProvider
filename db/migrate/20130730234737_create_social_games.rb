class CreateSocialGames < ActiveRecord::Migration
  def change
    create_table :social_games do |t|
      t.integer   :host_game_id
      t.integer   :host_user_id
      t.integer   :social_game_definition_id

      t.text      :participants_status
      t.integer   :participants_expected
      t.datetime  :date_taken
      t.string    :calling_ip
      t.string    :name

      t.timestamps
    end
  end
end
