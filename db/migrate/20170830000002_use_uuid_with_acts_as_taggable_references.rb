class UseUuidWithActsAsTaggableReferences < ActiveRecord::Migration[4.2]
  def up
    remove_column :taggings, :taggable_id
    add_column    :taggings, :taggable_id, :uuid

    remove_column :taggings, :tagger_id
    add_column    :taggings, :tagger_id, :uuid
  end

  def down
    remove_column :taggings, :taggable_id
    add_column    :taggings, :taggable_id, :integer

    remove_column :taggings, :tagger_id
    add_column    :taggings, :tagger_id, :integer
  end
end
