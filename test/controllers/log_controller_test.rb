require 'test_helper'

class LogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get log_index_url
    assert_response :success
  end

end
