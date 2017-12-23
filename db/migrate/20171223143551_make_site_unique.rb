class MakeSiteUnique < ActiveRecord::Migration[5.0]
  def up
    remove_index :cas_sites, :slug
    remove_index :cas_sites, :name
    add_index :cas_sites, :name, unique: true
    add_index :cas_sites, :slug, unique: true
  end

  def down
    remove_index :cas_sites, :slug
    remove_index :cas_sites, :name
    add_index :cas_sites, :slug, unique: false
    add_index :cas_sites, :name, unique: true
  end
end
