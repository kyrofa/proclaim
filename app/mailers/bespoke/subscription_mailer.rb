module Bespoke
	class SubscriptionMailer < ActionMailer::Base
		default from: "from@example.com"

		def welcome_email(subscription)
			@subscription = subscription

			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)
			base_url = root_url.gsub(/\A.*:\/\//, '').gsub(/\A(.*?)\/*\z/, '\1')

			mail to: @subscription.email, subject: "Welcome to #{base_url}!" do |format|
				format.html { message.to_inline_css }
				format.text { message.to_plain_text }
			end
		end

		def new_comment_notification_email(subscription, comment)
			@subscription = subscription
			@comment = comment

			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)

			mail to: @subscription.email,
			     subject: "New Comment On \"#{@comment.post.title}\"" do |format|
				format.html { message.to_inline_css }
				format.text { message.to_plain_text }
			end
		end

		def new_post_notification_email(subscription, post)
			@subscription = subscription
			@post = post

			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)

			mail to: @subscription.email,
			     subject: "New Post: #{@post.title}" do |format|
				format.html { message.to_inline_css }
				format.text { message.to_plain_text }
			end
		end
	end
end
