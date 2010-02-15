require 'test_helper'

class FeaturesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:features)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create feature" do
    assert_difference('Feature.count') do
      post :create, :feature => { }
    end

    assert_redirected_to feature_path(assigns(:feature))
  end

  test "should show feature" do
    get :show, :id => features(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => features(:one).to_param
    assert_response :success
  end

  test "should update feature" do
    put :update, :id => features(:one).to_param, :feature => { }
    assert_redirected_to feature_path(assigns(:feature))
  end

  test "should destroy feature" do
    assert_difference('Feature.count', -1) do
      delete :destroy, :id => features(:one).to_param
    end

    assert_redirected_to features_path
  end
end
