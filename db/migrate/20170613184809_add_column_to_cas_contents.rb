class AddColumnToCasContents < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :metadata, :string
  end
end
