class AddNoLogToCatalogEntries < ActiveRecord::Migration[5.0]
  def change
    add_column :catalog_entries, :no_log, :boolean, default: false
  end
end
