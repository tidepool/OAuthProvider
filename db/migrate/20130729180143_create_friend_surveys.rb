class CreateFriendSurveys < ActiveRecord::Migration
  def change
    create_table :friend_surveys do |t|
      t.integer :game_id
      t.text    :answers
      t.string  :calling_ip      
      t.timestamps
    end

    add_index :friend_surveys, :game_id
  end


end
