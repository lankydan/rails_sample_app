ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

# methods from here are used in unit tests
# if used from an integration test it will first check ActionDispatch (class below)
# and if one does not exist there with the same name it will use it from
# ActiveSupport instead
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    page_title + " | " + base_title
  end

  # Add more helper methods to be used by all tests here...
  # needed because helper methods are not available to use in tests
  # but ones defined in test_helper.rb can be used
  def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user)
    session[:user_id] = user.id
  end

end

# define test helper methods to be used in integration tests
# if the method is called from the test and it does not exist
# in this class it will take it from ActiveSupport (class above) instead
class ActionDispatch::IntegrationTest

  def log_in_as(user, password: "password", remember_me: "1")
    post login_path, params: { session: { email: user.email, password: password, remember_me: remember_me} }
  end

end

