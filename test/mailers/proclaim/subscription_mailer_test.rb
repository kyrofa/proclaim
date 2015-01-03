require 'test_helper'

module Proclaim
	class SubscriptionMailerTest < ActionMailer::TestCase
		include Rails.application.routes.url_helpers
		include Rails.application.routes.mounted_helpers

		def default_url_options
			Rails.application.config.action_mailer.default_url_options
		end

		setup do
			@edit_page = EditPage.new
		end

		test "welcome email" do
			subscription = FactoryGirl.create(:subscription)

			mail = SubscriptionMailer.welcome_email(subscription)
			assert_match "Welcome", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match proclaim.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match proclaim.unsubscribe_url(subscription.token), get_html_part(mail)
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
			assert_match proclaim.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match proclaim.unsubscribe_url(subscription.token), get_html_part(mail)
		end

		test "new post notification email" do
			subscription = FactoryGirl.create(:subscription)
			post = FactoryGirl.create(:published_post)

			mail = SubscriptionMailer.new_post_notification_email(subscription, post)
			assert_equal "New Post: #{post.title}", mail.subject
			assert_equal [subscription.email], mail.to
			assert_equal ["from@example.com"], mail.from
			assert_equal 2, mail.body.parts.length # Ensure multipart: text and HTML

			# Verify the email includes an unsubscription URL
			assert_match proclaim.unsubscribe_url(subscription.token), get_text_part(mail)
			assert_match proclaim.unsubscribe_url(subscription.token), get_html_part(mail)
		end

		test "images in new post notification email should have absolute URLs" do
			subscription = FactoryGirl.create(:subscription)

			image = FactoryGirl.create(:image)
			image.post.body = @edit_page.medium_inserted_image_html(image)
			image.post.publish
			image.post.save

			mail = SubscriptionMailer.new_post_notification_email(subscription, image.post)

			image_tags = Nokogiri::HTML(get_html_part(mail)).css("img")

			assert_equal 1, image_tags.length
			assert_match root_url, image_tags[0].attribute("src"),
				          "Images should have absolute URLs in emails"
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
