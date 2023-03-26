class CreateCasContentsToContentJoinTable < ActiveRecord::Migration[5.0]
  TABLE_NAME = :cas_content_to_contents

  def change
    create_table TABLE_NAME, id: :uuid do  |t|
      t.column :cas_content_id, :uuid
      t.text :relationship_type
      t.column :cas_other_section_id, :uuid
      t.column :cas_other_content_id, :uuid

      t.timestamps
    end

    add_index TABLE_NAME, [:cas_content_id, :cas_other_section_id, :cas_other_content_id],
      name: :cas_content_to_content_and_section
    add_index TABLE_NAME, :cas_other_content_id, name: :cas_content_to_content
  end
end
