require 'test_helper'

class SubscriptionEmailTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		ActionMailer::Base.deliveries.clear
	end

	test "should email welcome to post subscriber upon subscription" do
		post = FactoryGirl.create(:published_post)
		subscription = FactoryGirl.create(:subscription, post: post)

		# Make sure subscriber was sent a welcome email
		assert_equal [subscription.email], ActionMailer::Base.deliveries.last.to
		assert_match "Welcome", ActionMailer::Base.deliveries.last.subject
	end

	test "should email notification to post subscriber when new comment is made" do
		post = FactoryGirl.create(:published_post)
		subscription = FactoryGirl.create(:subscription, post: post)

		# Clear out emails-- new subscription probably sent a welcome email
		ActionMailer::Base.deliveries.clear

		comment = FactoryGirl.create(:comment, post: post)

		# Make sure subscriber was notified of new comment
		assert_equal [subscription.email], ActionMailer::Base.deliveries.last.to
		assert_equal "New Comment On \"#{post.title}\"", ActionMailer::Base.deliveries.last.subject
	end

	test "should not email post subscriber when old comment is edited" do
		post = FactoryGirl.create(:published_post)
		subscription = FactoryGirl.create(:subscription, post: post)
		comment = FactoryGirl.create(:comment, post: post)

		# Clear out emails that were just sent
		ActionMailer::Base.deliveries.clear

		comment.author = "Edit Author"
		comment.body = "Edit Body"
		comment.save

		# Make sure no email was sent after update
		assert_empty ActionMailer::Base.deliveries
	end

	test "should email notification to blog subscriber when post is published" do
		subscription = FactoryGirl.create(:subscription)

		# Clear out emails-- new subscription probably sent a welcome email
		ActionMailer::Base.deliveries.clear

		post = FactoryGirl.create(:published_post)

		# Make sure subscriber was notified of new post
		assert_equal [subscription.email], ActionMailer::Base.deliveries.last.to
		assert_equal "New Post: #{post.title}", ActionMailer::Base.deliveries.last.subject
	end

	test "should not email notification to blog subscriber when post is updated" do
		subscription = FactoryGirl.create(:subscription)
		post = FactoryGirl.create(:published_post)

		# Clear out all emails
		ActionMailer::Base.deliveries.clear

		post.title = "Edit Title"
		post.body = "Edit Body"

		# Make sure no email was sent after update
		assert_empty ActionMailer::Base.deliveries
	end

	test "should not email notification to blog subscriber if post is not published" do
		subscription = FactoryGirl.create(:subscription)

		# Clear out emails-- new subscription probably sent a welcome email
		ActionMailer::Base.deliveries.clear

		post = FactoryGirl.create(:post)

		# Make sure no email was sent after update
		assert_empty ActionMailer::Base.deliveries

		post.publish
		assert post.save

		# Make sure subscriber was notified of newly published post
		assert_equal [subscription.email], ActionMailer::Base.deliveries.last.to
		assert_equal "New Post: #{post.title}", ActionMailer::Base.deliveries.last.subject
	end
end
