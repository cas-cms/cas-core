class CreateCasUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_users do |t|
      t.string :name, null: false
      t.string :login, null: false
      t.string :password, null: false
      t.uuid :author_id
      t.string :roles, array: true, default: []

      t.timestamps
    end
  end
end
