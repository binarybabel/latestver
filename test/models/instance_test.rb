# == Schema Information
#
# Table name: instances
#
#  id               :integer          not null, primary key
#  group            :string           not null
#  catalog_entry_id :integer          not null
#  description      :string
#  version          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_instances_on_catalog_entry_id  (catalog_entry_id)
#

require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
