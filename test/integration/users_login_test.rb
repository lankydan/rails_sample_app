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
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path, count: 1
    assert_select "div.dropdown-menu" do |elements|
      assert_select "a[href=?]", user_path(@user), count: 1
    end
    assert is_logged_in?
  end

  test "login followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password"} }
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template "static_pages/home"
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
  test "login followed by logout + logout in another window" do
    get login_path
    post login_path, params: { session: { email: @user.email, password: "password"} }
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path # logout from another window
    follow_redirect!
    assert_template "static_pages/home"
    assert_select "a[href=?]", login_path, count: 1
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "remember me ticked user remembered" do
    log_in_as @user, remember_me: 1
    # for some reason you use the element name to the get value
    # cookies[:remember_me] cannot be used in test
    assert_not_nil cookies["remember_token"]
    # assigns can access instance variables that are in the actual code
    # so if I want to access user variable, make sure it is defined as @user
    # and use assigns(:user) to access its values
    assert_equal cookies["remember_token"], assigns(:user).remember_token
  end

  test "remember me not ticked user not remembered" do
    log_in_as @user, remember_me: 0
    assert_nil cookies["remember_token"]
  end

end
