class AddPublishedAtToCasContents < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :published_at, :datetime
    add_index :cas_contents, :published_at
  end
end
