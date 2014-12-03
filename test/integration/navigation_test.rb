require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)
	end

	test "get index" do
		visit '/bespoke/posts'
		assert_equal bespoke.posts_path, current_path
	end

	test "get new post without logging in" do
		visit '/bespoke/posts/new'
		assert_not_equal bespoke.new_post_path, current_path
		assert_match  /not authorized/, find('div.alert').text
	end

	test "get new post after logging in" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit '/bespoke/posts/new'
		assert_equal bespoke.new_post_path, current_path
	end
end
