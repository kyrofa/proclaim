require 'test_helper'

class BlogSubscriptionTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		ActionMailer::Base.deliveries.clear
	end

	test "should be able to create new blog subscription while logged in" do
		user = FactoryBot.create(:user)
		sign_in user

		visit proclaim.new_subscription_path

		within('#new_subscription') do
			fill_in 'Name', with: "example"
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: antispam_solution
		end

		assert_difference('Proclaim::Subscription.count', 1,
		                  "Should have successfully created subscription!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_text?("example"),
		       "Should be shown subscription name"
		assert page.has_no_text?("example@example.com"),
		       "Should not be shown email address, in case link is compromised"
	end

	test "should be able to create new blog subscription while not logged in" do
		visit proclaim.new_subscription_path

		within('#new_subscription') do
			fill_in 'Name', with: "example"
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: antispam_solution
		end

		assert_difference('Proclaim::Subscription.count', 1,
		                  "Should have successfully created subscription!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_text?("example"),
		       "Should be shown subscription name"
		assert page.has_no_text?("example@example.com"),
		       "Should not be shown email address, in case link is compromised"
	end

	test "should not be able to create new blog subscription if spammy" do
		user = FactoryBot.create(:user)
		sign_in user

		visit proclaim.new_subscription_path

		within('#new_subscription') do
			fill_in 'Name', with: "example"
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: "wrong answer"
		end

		assert_no_difference('Proclaim::Subscription.count',
		                     "Should have failed antispam questions!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_css?('div#error_explanation'),
			       "Should be shown errors since the antispam questions failed!"
	end

	test "catch missing name" do
		visit proclaim.new_subscription_path

		within('#new_subscription') do
			# Don't fill in name
			fill_in 'Email', with: "example@example.com"
			fill_in 'What is', with: antispam_solution
		end

		assert_no_difference('Proclaim::Subscription.count',
		                     "Should have caught missing name!") do
			find('#new_subscription input[type=submit]').click
		end

		assert page.has_css?('div#error_explanation')
	end

	test "catch bad email address" do
		visit proclaim.new_subscription_path

		within('#new_subscription') do
			fill_in 'Name', with: "example"
			fill_in 'Email', with: "bad_email_address"
			fill_in 'What is', with: antispam_solution
		end

		assert_no_difference('Proclaim::Subscription.count',
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
