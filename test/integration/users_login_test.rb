require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    # users because it is plural of the User model (:Dan is defined in users.yml)
    @user = users(:Dan)
  end

  test "invalid login flash displayed correctly" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: { email: "email@invalid", password: "password"} }
    assert_template "sessions/new"
    assert flash.any?
    get home_path
    assert flash.empty?
  end

  test "successful login" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password"} }
    assert_redirected_to @user
    follow_redirect!
    assert_template "user/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path, count: 1
    assert_select "a[href=?]", user_path(@user), count: 1
  end

  test "login followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password"} }
    assert_redirected_to @user
    follow_redirect!
    assert_template "user/show"
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

end
