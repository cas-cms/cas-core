class AddDescriptionToCasCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_categories, :description, :text
  end
end
