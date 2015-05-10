class CreateAuthentication < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :token
      t.string :token_secret
      t.references :user
    end
  end
end
