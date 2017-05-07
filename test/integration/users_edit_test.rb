require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
 
  def setup
    @user = users(:Dan)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: { user: { name: "", email: "test@invalid", password: "foo", password_confirmation: "bar"} }
    assert_template "users/edit"
    assert_select "div.alert"
    assert_select "div.alert-danger"
    assert_select "div", "The form contains 4 errors"
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    name = "updated name"
    email = "updated@email.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: "password", password_confirmation: "password"} }
    assert flash.any?
    assert_redirected_to @user
    @user.reload
    assert name, @user.name
    assert email, @user.email
  end

  test "not logged in" do
    get edit_user_path(@user)
    assert_redirected_to login_path
    follow_redirect!
    assert_template "sessions/new"
    assert flash.any?
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "updated name"
    email = "updated@email.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: "password", password_confirmation: "password"} }
    assert flash.any?
    assert_redirected_to @user
    @user.reload
    assert name, @user.name
    assert email, @user.email
  end

end
