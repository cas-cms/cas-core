class AddSlugToCasSections < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_sections, :slug, :string
  end
end
