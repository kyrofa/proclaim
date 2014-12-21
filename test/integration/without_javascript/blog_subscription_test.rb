require 'test_helper'

class BlogSubscriptionTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		ActionMailer::Base.deliveries.clear
	end

	test "should be able to create new blog subscription while logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find('#new_subscription input[type=submit]').click
			assert page.has_text? "Welcome"
		end
	end

	test "should be able to create new blog subscription while not logged in" do
		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find('#new_subscription input[type=submit]').click
			assert page.has_text? "Welcome"
		end
	end

	test "catch bad email address" do
		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "bad_email_address"
		end

		assert_no_difference('Bespoke::Subscription.count') do
			find('#new_subscription input[type=submit]').click
			assert page.has_css?('div#error_explanation')
		end
	end
end
