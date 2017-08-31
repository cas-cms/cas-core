class AddSearchIndexToCasContents < ActiveRecord::Migration[4.2]
  def up
    add_column :cas_contents, :tags_cache, :string
    execute <<-SQL
      CREATE INDEX cas_contents_search_with_fulltext ON cas_contents USING gist ((
        to_tsvector('simple', coalesce("cas_contents"."title"::text, ''))      ||
        to_tsvector('simple', coalesce("cas_contents"."text"::text, ''))       ||
        to_tsvector('simple', coalesce("cas_contents"."location"::text, ''))   ||
        to_tsvector('simple', coalesce("cas_contents"."tags_cache"::text, ''))
      ));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX cas_contents_search_with_fulltext;
    SQL
    remove_column :cas_contents, :tags_cache
  end
end
