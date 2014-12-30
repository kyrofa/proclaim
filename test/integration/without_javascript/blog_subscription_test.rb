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
			fill_in 'What is', with: antispam_solution
		end

		assert_difference('Bespoke::Subscription.count', 1,
		                  "Should have successfully created subscription!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_text?("Welcome"), "Should be shown the welcome page!"
	end

	test "should be able to create new blog subscription while not logged in" do
		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: antispam_solution
		end

		assert_difference('Bespoke::Subscription.count', 1,
		                  "Should have successfully created subscription!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_text?("Welcome"), "Should be shown the welcome page!"
	end

	test "should not be able to create new blog subscription if spammy" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: "wrong answer"
		end

		assert_no_difference('Bespoke::Subscription.count',
		                     "Should have failed antispam questions!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_css?('div#error_explanation'),
			       "Should be shown errors since the antispam questions failed!"
	end

	test "catch bad email address" do
		visit bespoke.new_subscription_path

		within('#new_subscription') do
			fill_in 'Email', with: "bad_email_address"
			fill_in 'What is', with: antispam_solution
		end

		assert_no_difference('Bespoke::Subscription.count',
		                     "Should have caught bad email address!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_css?('div#error_explanation')
	end

	private

	def antispam_solution
		find('input#antispam_solution', visible: false).value
	end
end
