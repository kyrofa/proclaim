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
		comment = FactoryGirl.build(:comment)

		# Verify that a user can create a comment
		policy = Bespoke::CommentPolicy.new(user, comment)
		assert policy.create?, "A user should be able to create comments!"

		# Verify that even without a user, a comment can still be created
		policy = Bespoke::CommentPolicy.new(nil, comment)
		assert policy.create?, "A guest should be able to create comments!"
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
