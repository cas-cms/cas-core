class CreateCasContents < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_contents, id: :uuid do  |t|
      t.column :section_id, :uuid
      t.string :title
      t.text :text
      t.column :author_id, :uuid
      t.datetime :date
      t.boolean :published

      t.timestamps
    end
    add_index :cas_contents, :section_id
    add_index :cas_contents, :author_id
    add_index :cas_contents, :published
  end
end
