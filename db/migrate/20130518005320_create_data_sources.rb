class CreateDataSources < ActiveRecord::Migration
  def change
    create_table :data_sources do |t|
      t.string  :name
      t.string  :description
      t.string  :logo_url
      t.string  :end_point_url
      t.string  :api_key
      t.string  :api_secret
      t.string  :retention_policy
      t.string  :rate_limit

      t.timestamps
    end
  end
end
