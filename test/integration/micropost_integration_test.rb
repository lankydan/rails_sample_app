require 'test_helper'

# Integration test for microposts
class MicropostIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:Dan)
    @other_user = users(:Laura)
    @micropost = microposts(:post_one)
  end

  test 'microposts are paginated' do
    log_in_as(@user)
    get root_url
    assert_select 'nav.pagination'
  end

  test 'invalid submission' do
    log_in_as(@user)
    get root_url
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: 'too long' * 50 } }
    end
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
    assert_select 'div.alert-danger'
  end

  test 'valid submission' do
    log_in_as(@user)
    get root_url
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: 'valid content' } }
    end
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'delete a post' do
    log_in_as(@user)
    get root_url
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(@micropost)
    end
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'no delete links on other users posts' do
    log_in_as(@user)
    get user_path(@other_user)
    @other_user.microposts.paginate(page: 1).each do |micropost|
      assert_select 'a[href=?]', micropost_path(micropost),
                    action: 'delete', text: 'delete', count: 0
    end
  end

  test 'upload picture with post' do
    picture = fixture_file_upload('test/fixtures/picture_uploader_test_files/rails.png')
    log_in_as(@user)
    get root_url
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: 'content', picture: picture } }
    end
    assert @user.microposts.first.picture?
  end

  test 'invalid file type cannot be uploaded' do
    picture = fixture_file_upload('test/fixtures/picture_uploader_test_files/invalid_file_format.txt')
    log_in_as(@user)
    get root_url
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: 'content', picture: picture } }
    end
    assert_not @user.microposts.first.picture?
  end

  test 'invalid submission with ajax' do
    log_in_as(@user)
    get root_url
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: 'too long' * 50 } }, xhr: true
    end
    assert_match "<div id=\\\"error_explanation\\\">", @response.body
    assert_match "<div class=\\\"alert alert-danger\\\">", @response.body
  end

end
