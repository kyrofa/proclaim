module Proclaim
	# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
	class SubscriptionMailerPreview < ActionMailer::Preview
		def welcome_email
			subscription = Subscription.first
			SubscriptionMailer.with(subscription_id: subscription.id).welcome_email
		end

		def new_post_notification_email
			subscription = Subscription.first
			post = Post.first
			SubscriptionMailer.with(subscription_id: subscription.id, post_id: post.id).new_post_notification_email.deliver_later
		end

		def new_comment_notification_email
			subscription = Subscription.where("post_id <> ''").first
			comment = subscription.post.comments.first
			SubscriptionMailer.with(subscription_id: subscription.id, comment_id: comment.id).new_comment_notification_email
		end
	end
end
