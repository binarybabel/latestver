class AddDescriptionToCatalogEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :catalog_entries, :description, :string
  end
end
