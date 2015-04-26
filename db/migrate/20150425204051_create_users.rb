class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_uid
      t.string :twitter_name
      t.string :withings_uid
      t.string :withings_name

      t.timestamps null: false
    end

    add_index :users, :twitter_uid, unique: true
    add_index :users, :withings_uid, unique: true
  end
end
