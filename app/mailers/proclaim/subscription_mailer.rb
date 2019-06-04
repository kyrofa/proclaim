module Proclaim
	class SubscriptionMailer < ApplicationMailer
		before_action :set_subscription

		def welcome_email
			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)
			base_url = root_url.gsub(/\A.*:\/\//, '').gsub(/\A(.*?)\/*\z/, '\1')

			mail to: @subscription.email, subject: "Welcome to #{base_url}!" do |format|
				format.html { message.to_inline_css }
				format.text { message.to_plain_text }
			end
		end

		def new_comment_notification_email
			@comment = Comment.find(params[:comment_id])

			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)

			mail to: @subscription.email,
				subject: "New Comment On \"#{@comment.post.title}\"" do |format|
					format.html { message.to_inline_css }
					format.text { message.to_plain_text }
			end
		end

		def new_post_notification_email
			@post = Post.find(params[:post_id])

			message = Premailer.new(render_to_string, with_html_string: true, base_url: root_url)

			mail to: @subscription.email,
				subject: "New Post: #{@post.title}" do |format|
					format.html { message.to_inline_css }
					format.text { message.to_plain_text }
			end
		end

		private

		def set_subscription
			@subscription = Subscription.find(params[:subscription_id])
		end
	end
end
