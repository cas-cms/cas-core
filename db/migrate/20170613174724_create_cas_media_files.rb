class CreateCasMediaFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_media_files do |t|
      t.uuid :attachable_id, polymorphic: true
      t.string :attachable_type, polymorphic: true
      t.references :attachable, polymorphic: true, index: true
      t.uuid :author_id
      t.string :service
      t.text :title
      t.string :url
      t.string :mime_type
      t.string :original_name
      t.integer :size
      t.text :file_data

      t.timestamps
    end
  end
end
