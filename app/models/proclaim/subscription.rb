# == Schema Information
#
# Table name: proclaim_subscriptions
#
#  id         :integer          not null, primary key
#  comment_id :integer
#  name       :string           default(""), not null
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Proclaim
	class Subscription < ActiveRecord::Base
		scope :blog_subscriptions, -> { where(comment_id: nil) }
		belongs_to :comment, inverse_of: :subscription, optional: true

		# Get the comment's post as our own
		delegate :post, to: :comment, allow_nil: true

		# Using after_commit since we use deliver_later and re-load them from the database
		after_create_commit :deliver_welcome_email
		after_create { Proclaim.notify_new_subscription(self) }

		# RFC-compliant email addresses are way nasty to match with regex, so why
		# try? We'll be sending them an email anyway-- if they don't get it, they
		# can re-subscribe. We'll just do an easy validation match here.
		validates :email, format: { with: /@/ }

		validates_presence_of :name

		# Subscriptions aren't required to belong to a comment, but if we're
		# given one it had better be valid
		validates_presence_of :comment, if: :comment_id

		validate :email_is_unique

		def deliver_welcome_email
			SubscriptionMailer.with(subscription_id: id).welcome_email.deliver_later
		end

		def deliver_new_post_notification_email(post)
			SubscriptionMailer.with(subscription_id: id, post_id: post.id).new_post_notification_email.deliver_later
		end

		def deliver_new_comment_notification_email(comment)
			SubscriptionMailer.with(subscription_id: id, comment_id: comment.id).new_comment_notification_email.deliver_later
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

		private

		def email_is_unique
			other_subscriptions = Subscription.where(email: email)
			unless other_subscriptions.empty?
				other_subscriptions.each do | other_subscription |
					if comment.nil? && other_subscription.comment.nil?
						errors.add(:email, "is already subscribed")
					elsif comment.try(:post) == other_subscription.comment.try(:post)
						errors.add(:email, "is already subscribed to comments on this post")
					end
				end
			end
		end
	end
end
