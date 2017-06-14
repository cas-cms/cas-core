class CreateCasCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_categories, id: :uuid do |t|
      t.uuid :section_id, null: false
      t.string :name, null: false
      t.string :slug
      t.jsonb :metadata, default: '{}'

      t.timestamps
    end
    add_index :cas_categories, :section_id
    add_index :cas_categories, :slug
  end
end
