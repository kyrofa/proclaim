module Bespoke
	class SubscriptionMailer < ActionMailer::Base
		default from: "from@example.com"

		def welcome_email(subscription)
			@subscription = subscription
			mail to: @subscription.email, subject: "Welcome!"
		end

		def new_comment_notification_email(subscription, comment)
			@subscription = subscription
			@comment = comment
			mail to: @subscription.email, subject: "New Comment On \"#{@comment.post.title}\""
		end

		def new_post_notification_email(subscription, post)
			@subscription = subscription
			@post = post
			mail to: @subscription.email, subject: "New Post: #{@post.title}"
		end
	end
end
