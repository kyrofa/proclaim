require 'test_helper'

class ApplicationPolicyTest < ActiveSupport::TestCase
	test "application index" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot visit the index by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.index?, "A user should be not able to visit the index by default"

		# Verify that a guest cannot visit the index by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.index?, "A guest should not be able to visit the index by default"
	end

	test "application show" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot view an object by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.show?, "A user should be not able to view an object by default"

		# Verify that a guest cannot view an object by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.show?, "A guest should not be able to view an object by default"
	end

	test "application create" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot create an object by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.create?, "A user should be not able to create an object by default"

		# Verify that a guest cannot create an object by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.create?, "A guest should not be able to create an object by default"
	end

	test "application new" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot visit the new action by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.new?, "A user should be not able to visit the new action by default"

		# Verify that a guest cannot visit the new action by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.new?, "A guest should not be able to visit the new action by default"
	end

	test "application update" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot update an object by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.update?, "A user should be not able to update an object by default"

		# Verify that a guest cannot update an object by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.update?, "A guest should not be able to update an object by default"
	end

	test "application edit" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot visit the edit action by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.edit?, "A user should be not able to visit the edit action by default"

		# Verify that a guest cannot visit the edit action by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.edit?, "A guest should not be able to visit the edit action by default"
	end

	test "application destroy" do
		user = FactoryGirl.create(:user)

		# Verify that a user cannot destroy an object by default
		policy = ApplicationPolicy.new(user, nil)
		refute policy.destroy?, "A user should be not able to destroy an object by default"

		# Verify that a guest cannot destroy an object by default
		policy = ApplicationPolicy.new(nil, nil)
		refute policy.destroy?, "A guest should not be able to destroy an object by default"
	end
end
