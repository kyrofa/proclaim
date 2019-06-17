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

require 'test_helper'

module Proclaim
	class SubscriptionTest < ActiveSupport::TestCase
		include ActionMailer::TestHelper

		test "blog subscriptions should be unique" do
			subscription = FactoryBot.create(:subscription, email: "foo@bar.com")
			subscription = FactoryBot.build(:subscription, email: subscription.email)
			refute subscription.save, "Blog subscriptions should have unique emails!"
		end

		test "post comment subscriptions should be unique" do
			subscription = FactoryBot.create(:post_comment_subscription, email: "foo@bar.com")
			comment = FactoryBot.create(:comment, post: subscription.post)
			subscription = FactoryBot.build(:post_comment_subscription, comment: comment, email: subscription.email)
			refute subscription.save, "Post comment subscriptions should have unique emails!"
		end

		test "blog subscription and post comment subscription emails need not be unique" do
			# Need to test both orders here. First, blog subscription exists first.
			subscription1 = FactoryBot.create(:subscription)
			comment = FactoryBot.create(:comment)
			subscription2 = FactoryBot.build(:post_comment_subscription, comment: comment, email: subscription1.email)
			assert subscription2.save, "The same email should be able to subscribe to the blog as well as post comments"

			# Now post comment subscription exists first
			comment = FactoryBot.create(:comment)
			subscription1 = FactoryBot.create(:post_comment_subscription, comment: comment)
			subscription2 = FactoryBot.build(:subscription, email: subscription1.email)
			assert subscription2.save, "The same email should be able to subscribe to the blog as well as post comments"
		end

		test "should require a name" do
			subscription = FactoryBot.build(:subscription, name: nil)
			refute subscription.save, "Subscription should require a name!"
		end

		test "should not save without valid email address" do
			subscription = FactoryBot.build(:subscription, email: nil)
			refute subscription.save, "Subscription should require an email address!"

			subscription = FactoryBot.build(:subscription, email: "blah")
			refute subscription.save, "Subscription should require a valid email address!"
		end

		test "token should be able to identify subscriptions" do
			subscription1 = FactoryBot.create(:subscription)
			subscription2 = FactoryBot.create(:subscription)

			token1 = subscription1.token
			token2 = subscription2.token

			assert_equal subscription1, Subscription.from_token(token1)
			assert_equal subscription2, Subscription.from_token(token2)
		end

		test "an invalid token should raise a NotFound" do
			assert_raises ActiveRecord::RecordNotFound do
				Subscription.from_token("123456")
			end
		end

		test "should require valid comment or none at all" do
			# Comment 12345 doesn't exist
			subscription = FactoryBot.build(:subscription, comment_id: 12345)
			refute subscription.save, "Subscription should require a valid comment!"

			subscription = FactoryBot.build(:subscription,
			                                 comment: FactoryBot.create(:published_comment))
			assert subscription.save

			subscription = FactoryBot.build(:subscription, comment: nil)
			assert subscription.save, "Subscription shouldn't require a comment!"
		end

		test "should deliver welcome email upon creation" do
			comment = FactoryBot.create(:published_comment)
			subscription = FactoryBot.build(:subscription, comment: comment)
			assert_enqueued_email_with SubscriptionMailer, :welcome_email, args: {subscription_id: (Subscription.maximum(:id).try(:next) || 0) + 1} do
				subscription.save
			end
		end
	end
end
