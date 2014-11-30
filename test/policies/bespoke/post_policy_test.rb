require 'test_helper'

class PostPolicyTest < ActiveSupport::TestCase
	test "post scope" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:post, published: true, publication_date: Date.today)

		# Verify that a user can see all posts
		posts = Pundit.policy_scope(user, Bespoke::Post)
		assert_includes posts, post1
		assert_includes posts, post2

		# Verify that guests can only see published posts
		posts = Pundit.policy_scope(nil, Bespoke::Post)
		assert_not_includes posts, post1
		assert_includes posts, post2
	end


	test "post create" do
		user = FactoryGirl.create(:user)
		post = FactoryGirl.create(:post)

		# Verify that a user can create posts
		policy = Bespoke::PostPolicy.new(user, post)
		assert policy.create?

		# Verify that guests can't create posts
		policy = Bespoke::PostPolicy.new(nil, post)
		refute policy.create?
	end

	test "post show" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:post, published: true, publication_date: Date.today)

		# Verify that a user can see both posts
		policy = Bespoke::PostPolicy.new(user, post1)
		assert policy.show?
		policy = Bespoke::PostPolicy.new(user, post2)
		assert policy.show?

		# Verify that a guest can only see published post
		policy = Bespoke::PostPolicy.new(nil, post1)
		refute policy.show?
		policy = Bespoke::PostPolicy.new(nil, post2)
		assert policy.show?
	end

	test "post update" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:post, published: true, publication_date: Date.today)

		# Verify that a user can update any post
		policy = Bespoke::PostPolicy.new(user, post1)
		assert policy.update?
		policy = Bespoke::PostPolicy.new(user, post2)
		assert policy.update?

		# Verify that guests can't update post
		policy = Bespoke::PostPolicy.new(nil, post1)
		refute policy.update?
		policy = Bespoke::PostPolicy.new(nil, post2)
		refute policy.update?
	end

	test "post destroy" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:post, published: true, publication_date: Date.today)

		# Verify that a user can destroy any post
		policy = Bespoke::PostPolicy.new(user, post1)
		assert policy.destroy?
		policy = Bespoke::PostPolicy.new(user, post2)
		assert policy.destroy?

		# Verify that guests can't destroy post
		policy = Bespoke::PostPolicy.new(nil, post1)
		refute policy.destroy?
		policy = Bespoke::PostPolicy.new(nil, post2)
		refute policy.destroy?
	end
end
