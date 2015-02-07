require 'test_helper'

class UnsubscribeTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)
	end

	test "should be able to unsubscribe from blog" do
		subscription = FactoryGirl.create(:subscription)

		visit proclaim.subscription_path(subscription.token)

		assert_difference('Proclaim::Subscription.count', -1) do
			click_button "Unsubscribe"
		end

		assert_equal proclaim.posts_path, current_path
	end

	test "should be able to unsubscribe from post" do
		subscription = FactoryGirl.create(:published_post_subscription)

		visit proclaim.subscription_path(subscription.token)

		assert_difference('Proclaim::Subscription.count', -1) do
			click_button "Unsubscribe"
		end

		assert_equal proclaim.posts_path, current_path
	end
end
