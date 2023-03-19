class MakeContentAuthorNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :cas_contents, :author_id, :uuid, null: true
  end
end
