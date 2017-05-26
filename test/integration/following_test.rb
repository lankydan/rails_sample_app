require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:Dan)
    @other_user = users(:Laura)
    log_in_as(@user)
  end

  test "correct number of followers displayed" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |follower|
      assert_select "a[href=?]", user_path(follower)
    end
  end

  test "correct number of following displayed" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |followed|
      assert_select "a[href=?]", user_path(followed)
    end
  end

  test "should follow user without ajax" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other_user.id }
    end
  end
  
  test "should unfollow user without ajax" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship)
    end
  end

  test "should follow user with ajax" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, params: { followed_id: @other_user.id }, xhr: true
    end
  end
  
  test "should unfollow user with ajax" do
    @user.follow(@other_user)
    relationship = @user.active_relationships.find_by(followed_id: @other_user.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

end