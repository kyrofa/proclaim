require "application_system_test_case"

module Proclaim
	class BlogSubscriptionTest < ApplicationSystemTestCase
		test "should be able to create new blog subscription while logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_subscription_path

			within('#new_subscription') do
				fill_in 'What is', with: antispam_solution
				fill_in 'Email', with: "example@example.com"
				fill_in 'Name', with: "example"
			end

			assert_difference('Proclaim::Subscription.count', 1,
							"Should have successfully created subscription!") do
				find('#new_subscription input[type=submit]').click
				assert page.has_text?("example"),
					"Should be shown subscription name"
				assert page.has_no_text?("example@example.com"),
					"Should not be shown email address, in case link is compromised"
			end
		end

		test "should be able to create new blog subscription while not logged in" do
			visit proclaim.new_subscription_path

			within('#new_subscription') do
				fill_in 'What is', with: antispam_solution
				fill_in 'Email', with: "example@example.com"
				fill_in 'Name', with: "example"
			end

			assert_difference('Proclaim::Subscription.count', 1,
							"Should have successfully created subscription!") do
				find('#new_subscription input[type=submit]').click
				assert page.has_text?("example"),
					"Should be shown subscription name"
				assert page.has_no_text?("example@example.com"),
					"Should not be shown email address, in case link is compromised"
			end
		end

		test "should not be able to create new blog subscription if spammy" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_subscription_path

			within('#new_subscription') do
				fill_in 'What is', with: "wrong answer"
				fill_in 'Email', with: "example@example.com"
				fill_in 'Name', with: "example"
			end

			assert_no_difference('Proclaim::Subscription.count',
								"Should have failed antispam questions!") do
				find('#new_subscription input[type=submit]').click
				assert page.has_css?('div#error_explanation'),
					"Should be shown errors since the antispam questions failed!"
			end
		end

		test "catch missing name" do
			visit proclaim.new_subscription_path

			within('#new_subscription') do
				# Don't fill in name
				fill_in 'What is', with: antispam_solution
				fill_in 'Email', with: "example@example.com"
			end

			assert_no_difference('Proclaim::Subscription.count',
								"Should have caught missing name!") do
				find('#new_subscription input[type=submit]').click
				assert page.has_css?('div#error_explanation')
			end
		end

		private

		def antispam_solution
			find('input#antispam_solution', visible: false).value
		end
	end
end
