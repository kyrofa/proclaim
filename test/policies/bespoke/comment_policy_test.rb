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
		assert policy.create?

		# Verify that even without a user, a comment can still be created
		policy = Bespoke::CommentPolicy.new(nil, comment)
		assert policy.create?
	end

	test "comment show" do
	end

	test "comment update" do
	end

	test "comment destroy" do
	end
end
