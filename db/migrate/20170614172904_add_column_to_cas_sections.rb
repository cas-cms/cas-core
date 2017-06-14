class AddColumnToCasSections < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_sections, :slug, :string
    add_index :cas_sections, :slug
  end
end
