# == Schema Information
#
# Table name: external_links
#
#  id               :integer          not null, primary key
#  catalog_entry_id :integer
#  name             :string
#  href             :string
#  icon             :string
#

require 'test_helper'

class ExternalLinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
