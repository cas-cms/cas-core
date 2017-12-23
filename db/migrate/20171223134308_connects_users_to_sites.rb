class ConnectsUsersToSites < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_sites_users, id: :uuid do |t|
      t.column :user_id, :uuid, null: false
      t.column :site_id, :uuid, null: false
      t.boolean :author_id, :uuid

      t.timestamps
    end

    add_index :cas_sites_users, [:site_id, :user_id]
  end
end
