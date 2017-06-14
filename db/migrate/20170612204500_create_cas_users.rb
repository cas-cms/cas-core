class CreateCasUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_users, id: :uuid do |t|
      t.string :name, null: false
      t.string :login
      t.string :password, null: false
      t.uuid :author_id
      t.string :roles, array: true, default: []

      t.timestamps
    end
    add_index :cas_users, :section_id
    add_index :cas_users, :author_id
  end
end
