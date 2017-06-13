class CreateCasCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_categories do |t|
      t.uuid :section_id
      t.string :name
      t.string :slug
      t.string :metadata

      t.timestamps
    end
  end
end
