require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:Dan)
    @other_user = users(:Laura)
  end
  
  test "should get signup page" do
    get signup_path
    assert_response :success
  end

  test "not logged in cant access edit page" do
    get edit_user_path(@user)
    assert_redirected_to login_path
    follow_redirect!
    assert_template "sessions/new"
    assert flash.any?
  end

  test "logged in can access edit page" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    assert flash.empty?
  end

  test "not logged in cant edit" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.name, password: "password", password_confirmation: "password"} }
    assert_redirected_to login_path
    follow_redirect!
    assert_template "sessions/new"
    assert flash.any?
end

  test "logged in can edit" do
    log_in_as(@user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.name, password: "password", password_confirmation: "password"} }
    assert_template "users/edit"
    assert flash.empty?
  end

  test "user cannot access another users edit page" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert_redirected_to root_url
  end

  test "user cannot edit another user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.name, password: "password", password_confirmation: "password"} }
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as @other_user
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: "password", password_confirmation: "password", admin: true} }
    assert_not @other_user.reload.admin?
  end

  test "admin user can delete user" do
    log_in_as @user
    assert @user.admin?
    delete user_path(@other_user)
    assert User.find_by(id: @other_user.id).nil?
  end

  test "non admin user cannot delete user" do
    log_in_as @other_user
    assert_not @other_user.admin?
    delete user_path(@user)
    assert_not User.find_by(id: @user.id).nil?
  end

  test "non admin user redirected to root page when delete user requested" do
    log_in_as @other_user
    assert_not @other_user.admin?
    delete user_path(@user)
    assert_redirected_to root_url
  end

  test "non logged in user redirected to login page when delete user requested" do
    delete user_path(@user)
    assert_redirected_to login_path
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
  

end
