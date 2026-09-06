# Serves listings ordered with Cas::Content.by_publication_date, which sorts
# on COALESCE(published_at, created_at) so rows without published_at keep
# their place. Postgres matches the index to the ORDER BY by function and
# argument order (table qualifiers do not matter), so those must stay in step
# with Cas::Content::PUBLICATION_DATE_SQL. Expression indexes have no column
# list, so only index_name_exists? can guard this one.
class AddPublicationDateIndexToCasContents < ActiveRecord::Migration[5.0]
  INDEX_NAME = "index_cas_contents_on_section_published_publication_date"

  def up
    return if index_name_exists?(:cas_contents, INDEX_NAME, false)

    add_index :cas_contents,
      "section_id, published, (COALESCE(published_at, created_at)) DESC, created_at DESC",
      name: INDEX_NAME
  end

  def down
    return unless index_name_exists?(:cas_contents, INDEX_NAME, false)

    remove_index :cas_contents, name: INDEX_NAME
  end
end
