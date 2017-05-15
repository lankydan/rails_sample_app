require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:Dan)
  end

  test "request reset valid email" do
    get new_password_reset_path
    assert_template "password_resets/new"
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not flash.empty?
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_url
  end

  test "request reset invalid email" do
    get new_password_reset_path
    assert_template "password_resets/new"
    post password_resets_path, params: { password_reset: { email: "invalid@email.com" } }
    assert_not flash.empty?
    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_template "password_resets/new"
  end

  test "reset password valid password" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "password", password_confirmation: "password" } }
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "reset password invalid password" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: user.email)
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "invalid", password_confirmation: "password" } }
    assert_not is_logged_in?
    assert flash.empty?
    assert_select "div#error_explanation"
    assert_template "password_resets/edit"
  end

  test "reset password empty password" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: user.email)
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "", password_confirmation: "" } }
    assert_not is_logged_in?
    assert flash.empty?
    assert_select "div#error_explanation"
    assert_template "password_resets/edit"
  end

  test "reset an inactive user" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
  end

  test "reset password wrong email" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    get edit_password_reset_path(user.reset_token, email: "wrong email")
    assert_redirected_to root_url
  end

  test "expired password reset cant call edit" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_response :redirect
    assert_not flash.empty?
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_match "expired", response.body
  end

  test "expired password reset cant call update" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "password", password_confirmation: "password" } }
    assert_not is_logged_in?
    assert_response :redirect
    assert_not flash.empty?
    assert_redirected_to new_password_reset_url
    follow_redirect!
    assert_match "expired", response.body
  end

  test "password reset already completed" do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "password", password_confirmation: "password" } }
    assert_nil user.reload.reset_digest
    post password_resets_path, params: { password_reset: { email: user.email } }
    assert_redirected_to root_url
  end

end
