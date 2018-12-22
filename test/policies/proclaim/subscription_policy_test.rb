require 'test_helper'

class SubscriptionPolicyTest < ActiveSupport::TestCase
	test "subscription scope" do
		user = FactoryBot.create(:user)
		subscription1 = FactoryBot.create(:subscription)
		subscription2 = FactoryBot.create(:subscription)

		# Verify that a user can view both subscriptions
		subscriptions = Pundit.policy_scope(user, Proclaim::Subscription)
		assert_includes subscriptions, subscription1
		assert_includes subscriptions, subscription2

		# Verify that without a user, no subscription can be seen
		subscriptions = Pundit.policy_scope(nil, Proclaim::Subscription)
		assert_empty subscriptions
	end

	test "subscription index" do
		user = FactoryBot.create(:user)

		# Verify that a user can visit the index
		policy = Proclaim::SubscriptionPolicy.new(user, Proclaim::Subscription)
		assert policy.index?, "A user should be able to visit the index"

		# Verify that a guest cannot visit the index
		policy = Proclaim::SubscriptionPolicy.new(nil, Proclaim::Subscription)
		refute policy.index?, "A guest should not be able to visit the index"
	end

	test "subscription show" do
		user = FactoryBot.create(:user)
		subscription = FactoryBot.create(:subscription)

		# Verify that a user can view a subscription
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		assert policy.show?, "A user should be able to view a subscription"

		# Verify that a guest can also view a subscription
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		assert policy.show?, "A guest should be able to view a subscription"
	end

	test "subscription creation" do
		user = FactoryBot.create(:user)

		# Verify that a user can create a subscription to the blog
		subscription = FactoryBot.build(:subscription)
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to the blog"

		# Verify that a user can create a subscription to an unpublished post
		subscription = FactoryBot.build(:post_subscription)
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to unpublished posts"

		# Verify that a user can create a subscription to a published post
		subscription = FactoryBot.build(:published_post_subscription)
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		assert policy.create?, "A user should be able to create subscriptions to published posts"

		# Verify that a guest can create a subscription to the blog
		subscription = FactoryBot.build(:subscription)
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		assert policy.create?, "A guest should be able to create subscriptions to the blog"

		# Verify that a guest cannot create a subscription to an unpublished post
		subscription = FactoryBot.build(:post_subscription)
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		refute policy.create?, "A guest should not be able to create subscriptions to unpublished posts"

		# Verify that a guest can create a subscription to a published post
		subscription = FactoryBot.build(:published_post_subscription)
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		assert policy.create?, "A guest should be able to create subscriptions to published posts"
	end

	test "subscription update" do
		user = FactoryBot.create(:user)
		subscription = FactoryBot.create(:subscription)

		# Verify that a even a user can't update a subscription
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		refute policy.update?, "A user should not be able to update subscriptions!"

		# Verify that a guest cannot update a subscription
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		refute policy.update?, "A guest should not be able to update subscription!"
	end

	test "subscription destroy" do
		user = FactoryBot.create(:user)
		subscription = FactoryBot.create(:subscription)

		# Verify that a user can destroy a subscription
		policy = Proclaim::SubscriptionPolicy.new(user, subscription)
		assert policy.destroy?, "A user should be able to destroy subscriptions!"

		# Verify that a guest can also destroy a subscription
		policy = Proclaim::SubscriptionPolicy.new(nil, subscription)
		assert policy.destroy?, "A guest should be able to destroy subscriptions!"
	end
end
