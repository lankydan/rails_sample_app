require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:Dan)
    @other_user = users(:Laura)
    @micropost = microposts(:post_one)
  end

  test "should redirect create when not logged in" do
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: {content: "content" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "Micropost.count" do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  # test "should redirect create when wrong user" do
  #   log_in_as(@other_user)
  #   assert_no_difference "Micropost.count" do
  #     post microposts_path, params: { micropost: {content: "content" } }
  #   end
  #   assert_redirected_to root_url
  # end

  test "should redirect destroy when wrong user" do
    log_in_as(@other_user)
    assert_no_difference "Micropost.count" do
      delete micropost_path(@micropost)
    end
    assert_redirected_to root_url
  end


end
