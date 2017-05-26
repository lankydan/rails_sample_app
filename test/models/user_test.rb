require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Dan", email: "test@hotmail.com", password: "password", password_confirmation: "password")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name is empty should be invalid" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "email is empty should be invalid" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name is not too long should be valid" do
    @user.name = "Dan"
    assert @user.valid?
  end

  test "name is too long should be invalid" do
    @user.email = "D" * 51
    assert_not @user.valid?
  end

  test "email is not too long should be valid" do
    @user.email = "test@hotmail.com"
    assert @user.valid?
  end

  test "email is too long should be invalid" do
    @user.email = "danknewton@hotmail.com" * 20 # >255 length
    assert_not @user.valid?
  end

  test "email validation should accept valid email addresses" do
    valid_addresses = %w[user@example.com USER@foo.com test@hotmail.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@bar.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid email addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@eample, foo@bar_bar.com foo@bar+baz.com a.com @com dan@dan..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be downcased before save" do
    upper_case_email = "DANKNEWTON@homtail.com"
    @user.email = upper_case_email
    @user.save
    assert_equal upper_case_email.downcase, @user.reload.email
  end

  test "password should be present (not blank)" do
    # @user.password = @user.password_confirmation = " " * 6
    @user.password = @user.password_confirmation = nil
    assert_not @user.valid?
  end

  test "passowrd should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    #@user.valid?
    #print @user.errors.messages
    assert_not @user.valid?
  end

  test "password over limit should be valid" do
    @user.password = @user.password_confirmation = "a" * 6
    assert @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

  test "destroying user cascades to microposts" do
    @user.save
    @user.microposts.create(content: "content")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "follow another user" do
    user = users(:Dan)
    other_user = users(:Laura)
    user.follow(other_user)
    assert user.following?(other_user)
  end

  test "unfollow another user" do
    user = users(:Dan)
    other_user = users(:Laura)
    user.follow(other_user)
    assert user.following?(other_user)
    user.unfollow(other_user)
    assert_not user.following?(other_user)
  end

  test "followed by another user" do
    user = users(:Dan)
    other_user = users(:Laura)
    other_user.follow(user)
    assert user.followed_by?(other_user)
  end

  test "feed should have the correct posts" do
    dan = users(:Dan)
    laura = users(:Laura)
    george = users(:George)
    # from followed user
    george.microposts.each do |post_following|
      assert dan.feed.include?(post_following)
    end
    # from self
    dan.microposts.each do |post_following|
      assert dan.feed.include?(post_following)
    end
    # from unfollowed user
    laura.microposts.each do |post_following|
      assert_not dan.feed.include?(post_following)
    end
  end
  
end
