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

require 'test_helper'

class CatalogWebhookTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
