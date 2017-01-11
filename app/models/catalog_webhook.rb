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
  validates_presence_of :catalog_entry, :url, :description

  belongs_to :catalog_entry

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
    end
    edit do
      field :catalog_entry
      field :url
      field :description
      field :last_triggered
      field :last_error
    end
  end
end
