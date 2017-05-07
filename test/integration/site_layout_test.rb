require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    get root_path
    @user = users(:Dan)
  end

  test "home page" do
    assert_template 'static_pages/home'
  end

  test "root path works" do
    assert_select "a[href=?]", root_path, count: 2
  end

  test "help path works" do
    assert_select "a[href=?]", help_path
  end

  test "about path works" do
    assert_select "a[href=?]", about_path, count: 2
  end

  test "contact path works" do
    assert_select "a[href=?]", contact_path
  end

  test "signup path works" do
    assert_select "a[href=?]", signup_path
  end
  
  test "logged in user can visit users page" do
    log_in_as @user
    get root_path
    get users_path
    assert_template "users/index"
  end

  test "not logged in user cannot visit users page" do
    get users_path
    assert_redirected_to login_url
    follow_redirect!
    assert_template "sessions/new"
  end

  test "logged in user sees account dropdown" do
    log_in_as @user
    get root_path
    assert_select "a[href=?]", "#"
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
  end

  test "not logged in user does not see account dropdown" do
    assert_select "a[href=?]", "#", count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
    assert_select "a[href=?]", edit_user_path(@user), count: 0
    assert_select "a[href=?]", logout_path, count: 0
  end

  test "logged in user does not see log in button" do
    log_in_as @user
    get root_path
    assert_select "a[href=?]", login_path, count: 0
  end

  test "not logged in user sees log in button" do
    assert_select "a[href=?]", login_path
  end

end
