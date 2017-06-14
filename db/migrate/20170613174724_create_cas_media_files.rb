class CreateCasMediaFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_media_files, id: :uuid do |t|
      t.references :attachable, polymorphic: true, index: true
      t.uuid :author_id, null: false
      t.string :service, null: false
      t.text :title
      t.string :url
      t.string :mime_type
      t.string :original_name
      t.integer :size
      t.text :file_data

      t.timestamps
    end
    add_index :cas_media_files, :author_id
  end
end
