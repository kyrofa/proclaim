require 'test_helper'

class CommentTest < ActionDispatch::IntegrationTest
	self.use_transactional_fixtures = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium
	end

	teardown do
		DatabaseCleaner.clean
		Capybara.use_default_driver
	end

	test "leave root comment" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		# Test leaving a root comment
		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			fill_in 'Body', with: "Comment Body"
		end
		find('#new_comment input[type=submit]').click
		assert page.has_css?('h3', text: 'Comment Title')
	end

	test "leave reply" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		# Test leaving a reply
		click_link "Reply"
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author"
			fill_in 'Title', with: "Reply Title"
			fill_in 'Body', with: "Reply Body"
		end
		find("#reply_to_#{comment.id}_new_comment input[type=submit]").click
		assert page.has_css?('h3', text: 'Reply Title')
	end

	test "should not have option to edit if not logged in" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		assert page.has_no_css?("#comment_#{comment.id} .edit"),
		       "A guest should not be given the option to edit a comment!"
	end

	test "edit root comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		comment = FactoryGirl.create(:published_comment,
		                             title: "Comment Title")

		visit bespoke.post_path(comment.post)

		find("#comment_#{comment.id} .edit").click
		assert page.has_no_css?('h3', text: 'Comment Title'),
		       "The comment should have been completely replaced by the edit form!"

		within("#edit_comment_#{comment.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Title', with: "Edit Title"
			fill_in 'Body', with: "Edit Body"
		end
		find("#edit_comment_#{comment.id} input[type=submit]").click
		assert page.has_css?('h3', text: 'Edit Title')
		assert page.has_no_css?('h3', text: 'Comment Title'),
		       "The old comment should be gone!"
	end

	test "edit parent comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment,
		                             title: "Parent Title")
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent,
		                           title: "Child Title")

		visit bespoke.post_path(parent.post)

		find("#comment_#{parent.id} .edit").click
		assert page.has_no_css?('h3', text: 'Parent Title'),
		       "The parent comment should have been completely replaced by the edit form!"
		assert page.has_css?('h3', text: 'Child Title'),
		       "The child comment should still be on the page!"

		within("#edit_comment_#{parent.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Title', with: "Edit Title"
			fill_in 'Body', with: "Edit Body"
		end
		find("#edit_comment_#{parent.id} input[type=submit]").click
		assert page.has_css?('h3', text: 'Edit Title')
		assert page.has_css?('h3', text: 'Child Title')
		assert page.has_no_css?('h3', text: 'Parent Title'),
		       "The old parent comment should be gone!"
	end

	test "edit child comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment,
		                             title: "Parent Title")
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent,
		                           title: "Child Title")

		visit bespoke.post_path(parent.post)

		find("#comment_#{child.id} .edit").click
		assert page.has_no_css?('h3', text: 'Child Title'),
		       "The child comment should have been completely replaced by the edit form!"
		assert page.has_css?('h3', text: 'Parent Title'),
		       "The parent comment should still be on the page!"

		within("#edit_comment_#{child.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Title', with: "Edit Title"
			fill_in 'Body', with: "Edit Body"
		end
		find("#edit_comment_#{child.id} input[type=submit]").click
		assert page.has_css?('h3', text: 'Edit Title')
		assert page.has_css?('h3', text: 'Parent Title')
		assert page.has_no_css?('h3', text: 'Child Title'),
		       "The old child comment should be gone!"
	end

	test "should not have option to delete if not logged in" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		assert page.has_no_css?("#comment_#{comment.id} .delete"),
		       "A guest should not be given the option to delete a comment!"
	end

	test "delete root comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		comment = FactoryGirl.create(:published_comment,
		                             title: "Comment Title")

		visit bespoke.post_path(comment.post)

		assert_difference('Bespoke::Comment.count', -1) do
			find("#comment_#{comment.id} .delete").click
			page.accept_alert
			assert page.has_no_css? 'h3', text: 'Comment Title'
		end
	end

	test "delete parent comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment,
		                             title: "Parent Title")
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent,
		                           title: "Child Title")

		visit bespoke.post_path(parent.post)

		assert_difference('Bespoke::Comment.count', -2) do
			find("#comment_#{parent.id} .delete").click
			page.accept_alert
			assert page.has_no_css? 'h3', text: 'Parent Title'
			assert page.has_no_css? 'h3', text: 'Child Title'
		end
	end

	test "delete child comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment,
		                             title: "Parent Title")
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent,
		                           title: "Child Title")

		visit bespoke.post_path(parent.post)

		assert_difference('Bespoke::Comment.count', -1) do
			find("#comment_#{child.id} .delete").click
			page.accept_alert
			assert page.has_css? 'h3', text: 'Parent Title'
			assert page.has_no_css? 'h3', text: 'Child Title'
		end
	end

	test "cancel button should remove errors" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			# Make a mistake-- leave out the body
		end
		find('#new_comment input[type=submit]').click

		# Errors should be on the page
		assert page.has_css?('div.error')

		# Now click cancel
		find('#new_comment button.cancel_comment').click

		# Now errors should be cleared
		assert page.has_no_css?('div.error')
	end
end
