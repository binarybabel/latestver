class AddCommandOptionToCatalogWebhooks < ActiveRecord::Migration[5.0]
  def up
    add_column :catalog_webhooks, :command, :string
    CatalogWebhook.update_all(command: 'curl -f -sS -X POST %{url}')
  end

  def down
    remove_column :catalog_webhooks, :command
  end
end
