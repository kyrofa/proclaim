require "application_system_test_case"

module Proclaim
	class ManageSubscriptionTest < ApplicationSystemTestCase
		test "should be able to see subscribers index if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			blog_subscription = FactoryBot.create(:subscription)
			post_subscription = FactoryBot.create(:published_post_comment_subscription)

			visit proclaim.subscriptions_path

			# Verify that the blog subscription is shown
			assert page.has_text?(blog_subscription.name),
				"Blog subscription name should be on the index"
			assert page.has_text?(blog_subscription.email),
				"Blog subscription email should be on the index"

			# Verify that the title of the post to which the post subscription belongs
			# is shown as well
			assert page.has_text?(post_subscription.post.title),
				"Post subscription's post's title should be on the index"

			# Finally, verify that the post subscription is shown
			assert page.has_text?(post_subscription.name),
				"Post subscription name should be on the index"
			assert page.has_text?(post_subscription.email),
				"Post subscription email should be on the index"
		end
	end
end