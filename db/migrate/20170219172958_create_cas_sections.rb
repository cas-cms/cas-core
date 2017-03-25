class CreateCasSections < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_sections, id: :uuid do |t|
      t.string :name, null: false
      t.string :section_type, null: false
      t.column :site_id, :uuid

      t.timestamps
    end
     add_index :cas_sections, :site_id
  end
end
