require 'test_helper'

module Bespoke
	class SubscriptionMailerTest < ActionMailer::TestCase
		include Rails.application.routes.url_helpers
		include Rails.application.routes.mounted_helpers

		def default_url_options
			Rails.application.config.action_mailer.default_url_options
		end

		test "welcome email" do
			subscription = FactoryGirl.create(:subscription)

			mail = SubscriptionMailer.welcome_email(subscription)
			assert_equal "Welcome!", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match bespoke.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match bespoke.unsubscribe_url(subscription.token), get_html_part(mail)
		end

		test "new comment notification email" do
			subscription = FactoryGirl.create(:post_subscription)
			comment = FactoryGirl.create(:comment)

			mail = SubscriptionMailer.new_comment_notification_email(subscription, comment)
			assert_equal "New Comment On \"#{comment.post.title}\"", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match bespoke.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match bespoke.unsubscribe_url(subscription.token), get_html_part(mail)
		end

		test "new post notification email" do
			subscription = FactoryGirl.create(:subscription)
			post = FactoryGirl.create(:post)

			mail = SubscriptionMailer.new_post_notification_email(subscription, post)
			assert_equal "New Post: #{post.title}", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match bespoke.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match bespoke.unsubscribe_url(subscription.token), get_html_part(mail)
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
