class AddColumnCategoryIdToCasContent < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :category_id, :uuid
    add_index :cas_contents, :category_id
  end
end
