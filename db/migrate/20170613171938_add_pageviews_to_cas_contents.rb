class AddPageviewsToCasContents < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_contents, :pageviews, :integer
  end
end
