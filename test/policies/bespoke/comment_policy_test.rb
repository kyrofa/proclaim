require 'test_helper'

class CommentPolicyTest < ActiveSupport::TestCase
	test "comment scope" do
		user = FactoryGirl.create(:user)
		comment1 = FactoryGirl.create(:comment)
		comment2 = FactoryGirl.create(:comment)

		# Verify that a user can view both comments
		comments = Pundit.policy_scope(user, Bespoke::Comment)
		assert_includes comments, comment1
		assert_includes comments, comment2

		# Verify that even without a user, both comments can still be viewed
		comments = Pundit.policy_scope(nil, Bespoke::Comment)
		assert_includes comments, comment1
		assert_includes comments, comment2
	end

	test "comment creation" do
		user = FactoryGirl.create(:user)
		publishedComment = FactoryGirl.build(:published_comment)
		unpublishedComment = FactoryGirl.build(:comment)

		# Verify that a user can create a comment on a published post
		policy = Bespoke::CommentPolicy.new(user, publishedComment)
		assert policy.create?,
		       "A user should be able to create comments on published posts!"

		# Verify that a user can create a comment on an unpublished post
		policy = Bespoke::CommentPolicy.new(user, unpublishedComment)
		assert policy.create?,
		       "A user should be able to create comments on unpublished posts!"

		# Verify that a guest can create a comment on a published post
		policy = Bespoke::CommentPolicy.new(nil, publishedComment)
		assert policy.create?,
		       "A guest should be able to create comments on published posts!"

		# Verify that a guest cannot create a comment on an unpublished post
		policy = Bespoke::CommentPolicy.new(nil, unpublishedComment)
		refute policy.create?,
		       "A guest should not be able to create comments on unpublished posts!"
	end

	test "comment update" do
		user = FactoryGirl.create(:user)
		comment = FactoryGirl.create(:comment)

		# Verify that a user can update a comment
		policy = Bespoke::CommentPolicy.new(user, comment)
		assert policy.update?, "A user should be able to update comments!"

		# Verify that a guest cannot update a comment
		policy = Bespoke::CommentPolicy.new(nil, comment)
		refute policy.update?, "A guest should not be able to update comments!"
	end

	test "comment destroy" do
		user = FactoryGirl.create(:user)
		comment = FactoryGirl.create(:comment)

		# Verify that a user can destroy a comment
		policy = Bespoke::CommentPolicy.new(user, comment)
		assert policy.destroy?, "A user should be able to destroy comments!"

		# Verify that a guest cannot destroy a comment
		policy = Bespoke::CommentPolicy.new(nil, comment)
		refute policy.destroy?, "A guest should not be able to destroy comments!"
	end
end
