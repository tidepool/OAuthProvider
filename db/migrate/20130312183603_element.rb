class Element < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.string   :name
      t.string   :version
      t.float    :standard_deviation
      t.float    :mean
      t.float    :weight_extraversion
      t.float    :weight_conscientiousness
      t.float    :weight_neuroticism
      t.float    :weight_openness
      t.float    :weight_agreeableness

      t.timestamps
    end
  end
end
