class DefaultCasContentsToPublished < ActiveRecord::Migration[5.0]
  # `published` was nullable with no default, so a row could be neither
  # published nor a draft. The admin never wrote such rows, but imports could,
  # and `where(published: true)` treats them as drafts while a direct URL
  # still served them. Saving has always published unless told otherwise, so
  # that is the default, and existing nulls become published so no URL that
  # served yesterday stops serving today.
  def up
    execute "UPDATE cas_contents SET published = true WHERE published IS NULL"
    change_column_default :cas_contents, :published, true
    change_column_null :cas_contents, :published, false
  end

  def down
    change_column_null :cas_contents, :published, true
    change_column_default :cas_contents, :published, nil
  end
end
