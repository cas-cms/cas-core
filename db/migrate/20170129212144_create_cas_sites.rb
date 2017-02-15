class CreateCasSites < ActiveRecord::Migration[5.0]
  def change
    create_table :cas_sites do |t|
      t.string :name

      t.timestamps
    end
    add_index :cas_sites, :name
  end
end
