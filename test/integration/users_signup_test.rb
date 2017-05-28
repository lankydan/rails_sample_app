require 'test_helper'
# tests signup page for correct validation
class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "valid signup information with valid account activation" do
    get new_user_path
    assert_difference "User.count" do
      post users_path, params: { user: { name:"Dan",
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
    get new_user_path
    post users_path, params: { user: { name:"Dan",
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
    get new_user_path
    post users_path, params: { user: { name:"Dan",
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
    get new_user_path
    post users_path, params: { user: { name:"Dan",
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
    get new_user_path
    post users_path, params: { user: { name:"Dan",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }
    user = assigns(:user)
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert is_logged_in?
  end

  test "invalid signup information" do
    get new_user_path
    assert_no_difference "User.count" do
      post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }
    end
    assert_template "users/new"
  end

  test "invalid signup errors are displayed" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }
    # selects the id name
    # <div id="error_explanation">
    assert_select "div#error_explanation"
    # seems to need to split the class up as it is made of many classes
    # <div class="alert alert-danger">
    assert_select "div.alert"
    assert_select "div.alert-danger"
  end

  test "invalid email error message" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }
    assert_select "li", "Email is invalid", count: 1
  end

  test "password is too short error message" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }
    assert_select "li", "Password is too short (minimum is 6 characters)", count: 1
  end

  test "passwords do not match error message" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "do not match"
                                        } }
    assert_select "li", "Password confirmation doesn't match Password", count: 1
  end

  test "all error messages displayed" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }
    assert_select "li", "Email is invalid", count: 1
    assert_select "li", "Password is too short (minimum is 6 characters)", count: 1
    assert_select "li", "Password confirmation doesn't match Password", count: 1
  end

  test "invalid signup information with ajax" do
    get new_user_path
    assert_no_difference "User.count" do
      post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }, xhr: true
    end
    assert_template "users/create"
    assert_template "users/_form"
    assert_template "shared/_error_messages"
    # assert_equal "Sign up", @response.body
  end

  test "invalid signup errors are displayed with ajax" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }, xhr: true
    assert_match "<div id=\\\"error_explanation\\\">", @response.body
    assert_match "<div class=\\\"alert alert-danger\\\">", @response.body
  end

  test "invalid email error message with ajax" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "password",
                                          password_confirmation: "password"
                                        } }, xhr: true                                
    assert_match "Email is invalid", @response.body
  end

  test "password is too short error message with ajax" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "foo",
                                          password_confirmation: "foo"
                                        } }, xhr: true
    assert_match "Password is too short (minimum is 6 characters)", @response.body
  end

  test "passwords do not match error message with ajax" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@valid.com",
                                          password: "password",
                                          password_confirmation: "do not match"
                                        } }, xhr: true
    assert_match "Password confirmation doesn&#39;t match Password", @response.body
  end

  test "all error messages displayed with ajax" do
    get new_user_path
    post users_path, params: { user: { name:"",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"
                                        } }, xhr: true  
    assert_match "Email is invalid", @response.body
    assert_match "Password is too short (minimum is 6 characters)", @response.body
    assert_match "Password confirmation doesn&#39;t match Password", @response.body
  end

end