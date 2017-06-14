class CreateCasSites < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        enable_extension "uuid-ossp"
      end
    end

    create_table :cas_sites, id: :uuid do |t|
      t.string :name
      t.timestamps
    end
    add_index :cas_sites, :name
  end
end
