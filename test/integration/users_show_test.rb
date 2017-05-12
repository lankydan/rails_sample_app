require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  
  def setup
    @active_user = users(:Dan)
    @inactive_user = users(:George)
  end

  test "cannot view unactivated user" do
    assert_not @inactive_user.activated?
    log_in_as @active_user
    get user_path @inactive_user
    assert_redirected_to root_url
  end

  test "can view activated user" do
    assert @active_user.activated?
    log_in_as @active_user
    get user_path @active_user
    assert_template "users/show"
  end

end
