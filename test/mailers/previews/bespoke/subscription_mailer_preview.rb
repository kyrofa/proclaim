module Bespoke
	# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
	class SubscriptionMailerPreview < ActionMailer::Preview
		def welcome_email
			subscription = Subscription.first
			SubscriptionMailer.welcome_email(subscription)
		end
	end
end
