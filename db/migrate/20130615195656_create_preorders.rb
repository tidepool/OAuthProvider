class CreatePreorders < ActiveRecord::Migration
  def change
    create_table :preorders do |t|
      t.integer :user_id

      t.timestamps
    end

  end
end
