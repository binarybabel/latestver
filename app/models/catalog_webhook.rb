# == Schema Information
#
# Table name: catalog_webhooks
#
#  id               :integer          not null, primary key
#  catalog_entry_id :integer          not null
#  url              :string           not null
#  description      :string           not null
#  last_triggered   :datetime
#  last_error       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_catalog_webhooks_on_catalog_entry_id  (catalog_entry_id)
#

class CatalogWebhook < ApplicationRecord
  validates_presence_of :catalog_entry, :url, :command, :description

  belongs_to :catalog_entry

  def trigger!
    self.last_triggered = DateTime.now
    self.last_error = nil
    begin
      cmd = self.command % catalog_entry.template_params.merge({url: url})
      out = `#{cmd} 2>&1`
      if $? != 0
        self.last_error = out
      end
    rescue => e
      self.last_error = e.message
    end
    save!
  end

  def self.model_help
    I18n.t 'admin.help.models.catalog_webhook'
  end

  rails_admin do
    navigation_label I18n.t 'app.nav.catalog'
    list do
      sort_by :catalog_entry
      field :catalog_entry do
        sortable 'catalog_entries.name, catalog_entries.tag'
        sort_reverse false
      end
      field :description
      field :last_triggered
      field :last_error
    end
    create do
      field :catalog_entry
      field :url
      field :description
      field :command do
        default_value 'curl -f -sS -X POST %{url}'
      end
    end
    edit do
      field :catalog_entry
      field :url
      field :description
      field :command
      field :last_triggered
      field :last_error
    end
  end
end
