require 'test_helper'

class ManageSubscriptionTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		ActionMailer::Base.deliveries.clear
	end

	test "should be able to see subscribers index if logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		blog_subscription = FactoryGirl.create(:subscription)
		post_subscription = FactoryGirl.create(:published_post_subscription)

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
