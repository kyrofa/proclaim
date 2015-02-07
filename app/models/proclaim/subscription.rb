# == Schema Information
#
# Table name: proclaim_subscriptions
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Proclaim
	class Subscription < ActiveRecord::Base
		scope :blog_subscriptions, -> { where(post_id: nil) }
		belongs_to :post, inverse_of: :subscriptions

		after_create :deliver_welcome_email
		after_create { Proclaim.notify_new_subscription(self) }

		# RFC-compliant email addresses are way nasty to match with regex, so why
		# try? We'll be sending them an email anyway-- if they don't get it, they
		# can re-subscribe. We'll just do an easy validation match here.
		validates :email, uniqueness: { scope: :post_id, case_sensitive: false }, format: { with: /@/ }

		validates_presence_of :name

		# Subscriptions aren't required to belong to a post, but if we're given
		# one it had better be valid
		validates_presence_of :post, if: :post_id

		def deliver_welcome_email
			SubscriptionMailer.welcome_email(self).deliver_later
		end

		def deliver_new_post_notification_email(post)
			SubscriptionMailer.new_post_notification_email(self, post).deliver_later
		end

		def deliver_new_comment_notification_email(comment)
			SubscriptionMailer.new_comment_notification_email(self, comment).deliver_later
		end

		def token
			Subscription.create_token(self)
		end

		def self.verifier
			ActiveSupport::MessageVerifier.new(Proclaim.secret_key)
		end

		def self.from_token(token)
			begin
				id = verifier.verify(token)
				Subscription.find(id)
			rescue ActiveSupport::MessageVerifier::InvalidSignature
				raise ActiveRecord::RecordNotFound
			end
		end

		def self.create_token(subscription)
			verifier.generate(subscription.id)
		end
	end
end
