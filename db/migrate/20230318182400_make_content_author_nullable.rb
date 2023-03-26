class MakeContentAuthorNullable < ActiveRecord::Migration[5.0]
  def up
    change_column :cas_contents, :author_id, :uuid, null: true
  end

  def down
    # We can't make it non-nullable again if there's already data in the
    # database
    change_column :cas_contents, :author_id, :uuid, null: true
  end
end
