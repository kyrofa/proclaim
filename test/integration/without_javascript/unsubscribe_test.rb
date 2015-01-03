require 'test_helper'

class UnsubscribeTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)
	end

	test "should be able to unsubscribe from blog" do
		subscription = FactoryGirl.create(:subscription)

		visit proclaim.unsubscribe_path(subscription.token)

		assert_difference('Proclaim::Subscription.count', -1) do
			click_link "unsubscribe"
		end

		assert_equal proclaim.unsubscribed_path, current_path
	end

	test "should be able to unsubscribe from post" do
		subscription = FactoryGirl.create(:published_post_subscription)

		visit proclaim.unsubscribe_path(subscription.token)

		assert_difference('Proclaim::Subscription.count', -1) do
			click_link "unsubscribe"
		end

		assert_equal proclaim.unsubscribed_path, current_path
	end
end
