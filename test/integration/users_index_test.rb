require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:Dan)
    @other_user = users(:Laura)
  end

  test "index including pagination" do
    log_in_as @user
    get users_path
    assert_template "users/index"
    assert_select "nav.pagination"
    User.where(activated: true).paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "admin user can delete user" do
    log_in_as @user
    get users_path
    assert_template "users/index"
    User.where(activated: true).paginate(page: 1).each do |user|
      unless user == @user
        assert_select "a[href=?]", user_path(user), text: "Delete"
      end
    end
    delete user_path(@other_user)
    assert User.find_by(id: @other_user.id).nil?
  end

  test "only display activated users" do
    log_in_as @user
    get users_path
    assert_template "users/index"
    assert_select "nav.pagination"
    User.where(activated: true).paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      assert user.activated?
    end
  end

end
