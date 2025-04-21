require "test_helper"

class IdeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ide_index_url
    assert_response :success
  end
end
