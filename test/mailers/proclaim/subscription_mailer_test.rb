require 'test_helper'

module Proclaim
	class SubscriptionMailerTest < ActionMailer::TestCase
		include Engine.routes.url_helpers

		test "welcome email" do
			subscription = FactoryBot.create(:subscription)

			mail = SubscriptionMailer.with(subscription_id: subscription.id).welcome_email
			assert_match "Welcome", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes a greeting
			assert_match "Hello, #{subscription.name}", get_text_part(mail)
			assert_match "Hello, #{subscription.name}", get_html_part(mail)

			# Verify the email includes an unsubscription URL
			assert_match subscription_url(subscription.token), get_text_part(mail)
			assert_match subscription_url(subscription.token), get_html_part(mail)
		end

		test "new comment notification email" do
			subscription = FactoryBot.create(:post_comment_subscription)
			comment = FactoryBot.create(:comment)

			mail = SubscriptionMailer.with(subscription_id: subscription.id, comment_id: comment.id).new_comment_notification_email
			assert_equal "New Comment On \"#{comment.post.title}\"", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match subscription_url(subscription.token), get_text_part(mail)
			assert_match subscription_url(subscription.token), get_html_part(mail)
		end

		test "new post notification email" do
			subscription = FactoryBot.create(:subscription)
			post = FactoryBot.create(:published_post)

			mail = SubscriptionMailer.with(subscription_id: subscription.id, post_id: post.id).new_post_notification_email
			assert_equal "New Post: #{post.title}", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match subscription_url(subscription.token), get_text_part(mail)
			assert_match subscription_url(subscription.token), get_html_part(mail)
		end

		private

		def get_text_part(mail)
			mail.body.parts.find {|p| p.content_type.match /plain/}.body.raw_source
		end

		def get_html_part(mail)
			mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source
		end
	end
end
