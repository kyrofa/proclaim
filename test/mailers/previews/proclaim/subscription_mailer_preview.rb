module Proclaim
	# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
	class SubscriptionMailerPreview < ActionMailer::Preview
		def welcome_email
			subscription = Subscription.first
			SubscriptionMailer.welcome_email(subscription)
		end

		def new_post_notification_email
			subscription = Subscription.first
			post = Post.first
			SubscriptionMailer.new_post_notification_email(subscription, post)
		end

		def new_comment_notification_email
			subscription = Subscription.where("post_id <> ''").first
			comment = subscription.post.comments.first

			SubscriptionMailer.new_comment_notification_email(subscription, comment)
		end
	end
end
