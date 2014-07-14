class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name, null: false
      t.text :description
      t.string :password
      t.string :admin_password, null: false

      t.timestamps
    end
  end
end
