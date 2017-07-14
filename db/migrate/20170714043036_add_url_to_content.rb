class AddUrlToContent < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :url, :string
  end
end
