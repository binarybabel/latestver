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

require 'test_helper'

class CatalogLogEntryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
