require "test_helper"

# test name must match the class it is testing correctly or it will not
# find the class and test will fail
class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:Dan)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when rememeber digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
    assert_not is_logged_in?
  end

end