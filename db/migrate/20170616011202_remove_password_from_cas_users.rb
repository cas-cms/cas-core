class RemovePasswordFromCasUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :cas_users, :password, :string, index: true
  end
end
