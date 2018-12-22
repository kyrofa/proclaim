require "application_system_test_case"

module Proclaim
	class UnsubscribeTest < ApplicationSystemTestCase
		include WaitForAjax

		test "should be able to unsubscribe from blog" do
			subscription = FactoryBot.create(:subscription)

			visit proclaim.subscription_path(subscription.token)

			assert_difference('Proclaim::Subscription.count', -1) do
				page.accept_confirm(/Are you sure.*/) do
					click_button "Unsubscribe"
				end
				assert page.has_text?("Successfully unsubscribed")
			end

			assert_equal proclaim.posts_path, current_path
		end

		test "should be able to unsubscribe from post" do
			subscription = FactoryBot.create(:published_post_subscription)

			visit proclaim.subscription_path(subscription.token)

			assert_difference('Proclaim::Subscription.count', -1) do
				page.accept_confirm(/Are you sure.*/) do
					click_button "Unsubscribe"
				end
				assert page.has_text?("Successfully unsubscribed")
			end

			assert_equal proclaim.posts_path, current_path
		end
	end
end
