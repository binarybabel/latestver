class CreateCatalogWebhooks < ActiveRecord::Migration[5.0]
  def change
    create_table :catalog_webhooks do |t|
      t.references :catalog_entry, foreign_key: true, null: false
      t.string :url, null: false
      t.string :description, null: false
      t.datetime :last_triggered
      t.string :last_error

      t.timestamps
    end
    add_column :catalog_log_entries, :webhook_triggered, :boolean, :default => false
  end
end
