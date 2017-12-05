class AddDomainsToCasSite < ActiveRecord::Migration[5.0]
  def change
    add_column :cas_sites, :domains, :string, array: true, default: []
    add_index :cas_sites, :domains, using: 'gin'
  end
end
