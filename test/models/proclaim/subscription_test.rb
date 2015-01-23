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
			FactoryGirl.create(:subscription, email: "foo@bar.com")
			subscription = FactoryGirl.build(:subscription, email: "foo@bar.com")
			refute subscription.save,
			       "Blog subscriptions should have unique emails!"

			subscription = FactoryGirl.create(:post_subscription, email: "foo@bar.com")
			subscription = FactoryGirl.build(:post_subscription,
			                                 post: subscription.post,
			                                 email: subscription.email)
			refute subscription.save,
			       "Post subscriptions should have unique emails!"
		end

		test "should require a name" do
			subscription = FactoryGirl.build(:subscription, name: nil)
			refute subscription.save, "Subscription should require a name!"
		end

		test "should not save without valid email address" do
			subscription = FactoryGirl.build(:subscription, email: nil)
			refute subscription.save,
			       "Subscription should require an email address!"

			subscription = FactoryGirl.build(:subscription, email: "blah")
			refute subscription.save,
			       "Subscription should require a valid email address!"
		end

		test "token should be able to identify subscriptions" do
			subscription1 = FactoryGirl.create(:subscription)
			subscription2 = FactoryGirl.create(:subscription)

			token1 = subscription1.token
			token2 = subscription2.token

			assert_equal subscription1, Subscription.from_token(token1)
			assert_equal subscription2, Subscription.from_token(token2)
		end

		test "should require valid post or none at all" do
			# Post 12345 doesn't exist
			subscription = FactoryGirl.build(:subscription, post_id: 12345)
			refute subscription.save,
			       "Subscription should require a valid post!"

			subscription = FactoryGirl.build(:subscription,
			                                 post: FactoryGirl.create(:published_post))
			assert subscription.save

			subscription = FactoryGirl.build(:subscription, post: nil)
			assert subscription.save,
			       "Subscription shouldn't require a post!"
		end
	end
end
