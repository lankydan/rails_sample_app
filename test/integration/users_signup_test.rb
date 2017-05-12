require 'test_helper'
# tests signup page for correct validation
class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "valid signup information with valid account activation" do
    get signup_path
    assert_difference "User.count" do
      post signup_path, params: { user: { name:"Dan",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
  end

  test "valid signup information with invalid token account activation" do
    get signup_path
    post signup_path, params: { user: { name:"Dan",
                                        email: "user@valid.com",
                                        password: "password",
                                        password_confirmation: "password"
                                      } }
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not user.reload.activated?
    follow_redirect!
    assert_template "static_pages/home"
    assert_not is_logged_in?
  end

  test "valid signup information with wrong email account activation" do
    get signup_path
    post signup_path, params: { user: { name:"Dan",
                                        email: "user@valid.com",
                                        password: "password",
                                        password_confirmation: "password"
                                      } }
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    get edit_account_activation_path(user.activation_token, email: "invalid")
    assert_not user.reload.activated?
    follow_redirect!
    assert_template "static_pages/home"
    assert_not is_logged_in?
  end

  test "valid signup success flash displayed" do
    get signup_path
    post signup_path, params: { user: { name:"Dan",
                                        email: "user@valid.com",
                                        password: "password",
                                        password_confirmation: "password"
                                      } }
    user = assigns(:user)
    get edit_account_activation_path(user.activation_token, email: user.email)
    follow_redirect!
    assert flash.any?
    # makes the code brittle to search for text / :success is in the flash hash
    assert flash.key? :success # checks if :success key exists in the flash hash
    assert_select "div.alert", count: 1
    assert_select "div.alert-success", "Account activated!", count: 1
  end

  test "valid signup user logged in" do
    get signup_path
    post signup_path, params: { user: { name:"Dan",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }
    user = assigns(:user)
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert is_logged_in?
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }
    end
    assert_template "users/new"
  end

  test "invalid signup errors are displayed" do
    get signup_path
    post signup_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }
    assert_template "users/new"
    # selects the id name
    # <div id="error_explanation">
    assert_select "div#error_explanation"
    # seems to need to split the class up as it is made of many classes
    # <div class="alert alert-danger">
    assert_select "div.alert"
    assert_select "div.alert-danger"
  end

  test "invalid email error message" do
    get signup_path
    post signup_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }
    assert_template "users/new"
    assert_select "li", "Email is invalid", count: 1
  end

  test "password is too short error message" do
    get signup_path
    post signup_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }
    assert_template "users/new"
    assert_select "li", "Password is too short (minimum is 6 characters)", count: 1
  end

  test "passwords do not match error message" do
    get signup_path
    post signup_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "do not match"
                                        } }
    assert_template "users/new"
    assert_select "li", "Password confirmation doesn't match Password", count: 1
  end

  test "all error messages displayed" do
    get signup_path
    post signup_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }
    assert_template "users/new"
    assert_select "li", "Email is invalid", count: 1
    assert_select "li", "Password is too short (minimum is 6 characters)", count: 1
    assert_select "li", "Password confirmation doesn't match Password", count: 1
  end

end