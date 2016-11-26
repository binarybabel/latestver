class AddHiddenToCatalogEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :catalog_entries, :hidden, :boolean, default: false
  end
end
