require 'test_helper'

class CartControllerTest < ActionController::TestCase
  test "should get get" do
    get :get
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

end
