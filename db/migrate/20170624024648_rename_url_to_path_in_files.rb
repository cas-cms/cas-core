class RenameUrlToPathInFiles < ActiveRecord::Migration[5.0]
  def change
    rename_column :cas_media_files, :url, :path
    rename_column :cas_media_files, :title, :description
    add_column :cas_media_files, :media_type, :string, null: false
  end
end
