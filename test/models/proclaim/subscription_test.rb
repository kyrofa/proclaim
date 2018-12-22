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

require 'test_helper'

module Proclaim
	class SubscriptionTest < ActiveSupport::TestCase
		test "subscriptions should be unique" do
			FactoryBot.create(:subscription, email: "foo@bar.com")
			subscription = FactoryBot.build(:subscription, email: "foo@bar.com")
			refute subscription.save,
			       "Blog subscriptions should have unique emails!"

			subscription = FactoryBot.create(:post_subscription, email: "foo@bar.com")
			subscription = FactoryBot.build(:post_subscription,
			                                 post: subscription.post,
			                                 email: subscription.email)
			refute subscription.save,
			       "Post subscriptions should have unique emails!"
		end

		test "should require a name" do
			subscription = FactoryBot.build(:subscription, name: nil)
			refute subscription.save, "Subscription should require a name!"
		end

		test "should not save without valid email address" do
			subscription = FactoryBot.build(:subscription, email: nil)
			refute subscription.save,
			       "Subscription should require an email address!"

			subscription = FactoryBot.build(:subscription, email: "blah")
			refute subscription.save,
			       "Subscription should require a valid email address!"
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

		test "should require valid post or none at all" do
			# Post 12345 doesn't exist
			subscription = FactoryBot.build(:subscription, post_id: 12345)
			refute subscription.save,
			       "Subscription should require a valid post!"

			subscription = FactoryBot.build(:subscription,
			                                 post: FactoryBot.create(:published_post))
			assert subscription.save

			subscription = FactoryBot.build(:subscription, post: nil)
			assert subscription.save,
			       "Subscription shouldn't require a post!"
		end
	end
end
