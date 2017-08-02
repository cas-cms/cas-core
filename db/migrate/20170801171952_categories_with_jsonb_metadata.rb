class CategoriesWithJsonbMetadata < ActiveRecord::Migration[5.0]
  def change
    remove_column :cas_categories, :metadata, :string, default: "{}"
    add_column :cas_categories, :metadata, :jsonb, default: {}
  end
end
