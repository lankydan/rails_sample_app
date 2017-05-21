require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:Dan)
  end

  test "user information displayed" do
    get user_path(@user)
    assert_template "users/show"
    assert_select "title", full_title(@user.name)
    assert_select "h1", text: @user.name
    assert_select "h1>img.gravatar"
  end

  test "microposts displayed" do
    get user_path(@user)
    assert_match @user.microposts.count.to_s, response.body
    assert_select "nav.pagination"
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

end
