class PageviewsDefaultToZero < ActiveRecord::Migration[5.0]
  def up
    change_column :cas_contents, :pageviews, :integer, default: 0
  end

  def down
    change_column :cas_contents, :pageviews, :integer, default: nil
  end
end
