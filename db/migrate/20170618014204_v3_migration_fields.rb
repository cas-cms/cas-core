class V3MigrationFields < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_sites, :slug, :string
    add_column :cas_users, :metadata, :jsonb, default: {}
    add_column :cas_media_files, :cover, :boolean, null: false, default: false
    add_column :cas_media_files, :order, :integer, default: 1
    add_column :cas_media_files, :text, :text
    add_column :cas_media_files, :metadata, :jsonb, default: {}

    reversible do |dir|
      dir.up   do
        change_column :cas_users,
          :email,
          :string,
          null: true,
          default: nil
        change_column :cas_media_files,
          :author_id,
          :uuid,
          null: true
      end
      dir.down do
      end
    end

    add_index :cas_sites, :slug
    add_index :cas_users, :encrypted_password
    add_index :cas_media_files, :cover
  end
end
