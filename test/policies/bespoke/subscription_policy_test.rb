require 'test_helper'

class SubscriptionPolicyTest < ActiveSupport::TestCase
	test "subscription scope" do
		user = FactoryGirl.create(:user)
		subscription1 = FactoryGirl.create(:subscription)
		subscription2 = FactoryGirl.create(:subscription)

		# Verify that a user can view both subscriptions
		subscriptions = Pundit.policy_scope(user, Bespoke::Subscription)
		assert_includes subscriptions, subscription1
		assert_includes subscriptions, subscription2

		# Verify that without a user, no subscription can be seen
		subscriptions = Pundit.policy_scope(nil, Bespoke::Subscription)
		assert_nil subscriptions
	end

	test "subscription creation" do
		user = FactoryGirl.create(:user)

		# Verify that a user can create a subscription to the blog
		subscription = FactoryGirl.build(:subscription)
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to the blog"

		# Verify that a user can create a subscription to an unpublished post
		subscription = FactoryGirl.build(:post_subscription)
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to unpublished posts"

		# Verify that a user can create a subscription to a published post
		subscription = FactoryGirl.build(:published_post_subscription)
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to published posts"

		# Verify that a guest can create a subscription to the blog
		subscription = FactoryGirl.build(:subscription)
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		assert policy.create?, "A guest should be able to create subscriptions to the blog"

		# Verify that a guest cannot create a subscription to an unpublished post
		subscription = FactoryGirl.build(:post_subscription)
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		refute policy.create?, "A guest should not be able to create subscriptions to unpublished posts"

		# Verify that a guest can create a subscription to a published post
		subscription = FactoryGirl.build(:published_post_subscription)
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		assert policy.create?, "A guest should be able to create subscriptions to published posts"
	end

	test "subscription update" do
		user = FactoryGirl.create(:user)
		subscription = FactoryGirl.create(:subscription)

		# Verify that a even a user can't update a subscription (for now)
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		refute policy.update?, "A user should not be able to update subscriptions!"

		# Verify that a guest cannot update a subscription
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		refute policy.update?, "A guest should not be able to update subscription!"
	end

	test "subscription unsubscribe" do
		user = FactoryGirl.create(:user)
		subscription = FactoryGirl.create(:subscription)

		# Verify that a user can unsubscribe
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		assert policy.unsubscribe?, "A user should be able to unsubscribe!"

		# Verify that a guest can also unsubscribe
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		assert policy.unsubscribe?, "A guest should be able to unsubscribe!"
	end

	test "subscription destroy" do
		user = FactoryGirl.create(:user)
		subscription = FactoryGirl.create(:subscription)

		# Verify that a user can destroy a subscription
		policy = Bespoke::SubscriptionPolicy.new(user, subscription)
		assert policy.destroy?, "A user should be able to destroy subscriptions!"

		# Verify that a guest can also destroy a subscription
		policy = Bespoke::SubscriptionPolicy.new(nil, subscription)
		assert policy.destroy?, "A guest should be able to destroy subscriptions!"
	end
end
