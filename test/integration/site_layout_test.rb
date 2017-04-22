require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  
  def setup
    get root_path
  end

  test "home page" do
    assert_template 'static_pages/home'
  end

  test "root path works" do
    assert_select "a[href=?]", root_path, count: 2
  end

  test "help path works" do
    assert_select "a[href=?]", help_path
  end

  test "about path works" do
    assert_select "a[href=?]", about_path, count: 2
  end

  test "contact path works" do
    assert_select "a[href=?]", contact_path
  end

  test "signup path works" do
    assert_select "a[href=?]", signup_path
  end

end
