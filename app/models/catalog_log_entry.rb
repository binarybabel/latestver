# == Schema Information
#
# Table name: catalog_log_entries
#
#  id                :integer          not null, primary key
#  catalog_entry_id  :integer          not null
#  version_from      :string
#  version_to        :string
#  webhook_triggered :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_catalog_log_entries_on_catalog_entry_id  (catalog_entry_id)
#

class CatalogLogEntry < ApplicationRecord
  validates_presence_of :catalog_entry

  belongs_to :catalog_entry

  rails_admin do
    list do
      sort_by :created_at
      field :created_at
      field :catalog_entry
      field :version_from
      field :version_to
      field :webhook_triggered
    end
  end
end
