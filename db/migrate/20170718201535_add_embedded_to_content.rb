class AddEmbeddedToContent < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :embedded, :string
  end
end
