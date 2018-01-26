class AlterCasUsersToCasPeople < ActiveRecord::Migration[5.0]
  def change
    remove_index :cas_activities, :user_id
    rename_column :cas_activities, :user_id, :person_id
    remove_index :cas_sites_users, [:site_id, :user_id]
    rename_table :cas_users, :cas_people
    rename_table :cas_sites_users, :cas_people_sites
    rename_column :cas_people_sites, :user_id, :person_id
    add_index :cas_people_sites, [:site_id, :person_id], using: "btree"
    add_index :cas_activities, :person_id, using: "btree"
  end
end
