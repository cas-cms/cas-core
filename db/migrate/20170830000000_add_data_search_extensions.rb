class AddDataSearchExtensions < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE EXTENSION fuzzystrmatch;
      CREATE EXTENSION pg_trgm;
      CREATE EXTENSION unaccent;
    SQL
  end

  def down
    execute <<-SQL
      DROP EXTENSION pg_trgm;
      DROP EXTENSION unaccent;
      DROP EXTENSION fuzzystrmatch;
    SQL
  end
end
