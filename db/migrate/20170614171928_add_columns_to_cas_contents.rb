class AddColumnsToCasContents < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :pageviews, :integer
    add_column :cas_contents, :metadata, :jsonb, default: '{}'
    add_column :cas_contents, :summary, :text
    add_column :cas_contents, :details, :jsonb, default: '{}'
    add_column :cas_contents, :slug, :string
    change_column :cas_contents, :section_id, :uuid, null: false
    change_column :cas_contents, :author_id, :uuid, null: false
    add_index :cas_contents, :slug
  end
end
