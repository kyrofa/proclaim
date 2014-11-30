require 'test_helper'

class CommentPolicyTest < ActiveSupport::TestCase
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

  def test_scope
  end

  def test_create
  end

  def test_show
  end

  def test_update
  end

  def test_destroy
  end
end
