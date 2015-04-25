class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid
      t.string :withings_uid

      t.timestamps null: false
    end
  end
end
