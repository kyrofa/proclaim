require 'test_helper'

class PostPolicyTest < ActiveSupport::TestCase
	test "post scope" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:published_post)

		# Verify that a user can see all posts
		posts = Pundit.policy_scope(user, Proclaim::Post)
		assert_includes posts, post1
		assert_includes posts, post2

		# Verify that guests can only see published posts
		posts = Pundit.policy_scope(nil, Proclaim::Post)
		assert_not_includes posts, post1
		assert_includes posts, post2
	end

	test "post index" do
		user = FactoryGirl.create(:user)

		# Verify that a user can visit the index
		policy = Proclaim::PostPolicy.new(user, Proclaim::Post)
		assert policy.index?, "A user should be able to visit the index"

		# Verify that a guest can also visit the index
		policy = Proclaim::PostPolicy.new(nil, Proclaim::Post)
		assert policy.index?, "A guest should be able to visit the index"
	end

	test "post create" do
		user = FactoryGirl.create(:user)
		post = FactoryGirl.create(:post)

		# Verify that a user can create posts
		policy = Proclaim::PostPolicy.new(user, post)
		assert policy.create?

		# Verify that guests can't create posts
		policy = Proclaim::PostPolicy.new(nil, post)
		refute policy.create?
	end

	test "post show" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:published_post)

		# Verify that a user can see both posts
		policy = Proclaim::PostPolicy.new(user, post1)
		assert policy.show?
		policy = Proclaim::PostPolicy.new(user, post2)
		assert policy.show?

		# Verify that a guest can only see published post
		policy = Proclaim::PostPolicy.new(nil, post1)
		refute policy.show?
		policy = Proclaim::PostPolicy.new(nil, post2)
		assert policy.show?
	end

	test "post update" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:published_post)

		# Verify that a user can update any post
		policy = Proclaim::PostPolicy.new(user, post1)
		assert policy.update?
		policy = Proclaim::PostPolicy.new(user, post2)
		assert policy.update?

		# Verify that guests can't update post
		policy = Proclaim::PostPolicy.new(nil, post1)
		refute policy.update?
		policy = Proclaim::PostPolicy.new(nil, post2)
		refute policy.update?
	end

	test "post destroy" do
		user = FactoryGirl.create(:user)
		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:published_post)

		# Verify that a user can destroy any post
		policy = Proclaim::PostPolicy.new(user, post1)
		assert policy.destroy?
		policy = Proclaim::PostPolicy.new(user, post2)
		assert policy.destroy?

		# Verify that guests can't destroy post
		policy = Proclaim::PostPolicy.new(nil, post1)
		refute policy.destroy?
		policy = Proclaim::PostPolicy.new(nil, post2)
		refute policy.destroy?
	end
end
