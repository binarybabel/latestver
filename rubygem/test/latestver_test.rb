require 'test_helper'

class LatestverTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Latestver::VERSION
  end
end
