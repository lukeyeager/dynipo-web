class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.integer :server_id, null: false
      t.string :ip_address

      t.timestamps
    end
  end
end
