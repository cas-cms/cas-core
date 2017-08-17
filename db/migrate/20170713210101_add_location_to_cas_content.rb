class AddLocationToCasContent < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :location, :string
  end
end
