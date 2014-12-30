require 'test_helper'

class CommentTest < ActionDispatch::IntegrationTest
	self.use_transactional_fixtures = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium

		@show_page = ShowPage.new
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
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
		end

		@show_page.new_comment_submit_button.click

		assert page.has_no_css?('div.error')
		assert page.has_text? "Comment Author"
		assert page.has_text? "Comment Body"
	end

	test "leave two replies" do
		comment = FactoryGirl.create(:published_comment)
		post = comment.post

		visit bespoke.post_path(post)

		# Leave first reply
		@show_page.comment_reply_link(comment).click
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author 1"
			fill_in 'Body', with: "Reply Body 1"
			fill_in 'What is', with: @show_page.antispam_solution(comment)
		end

		@show_page.new_comment_submit_button(comment).click

		assert page.has_no_css?('div.error')
		assert page.has_text? "Reply Author 1"
		assert page.has_text? "Reply Body 1"

		# Leave second reply
		@show_page.comment_reply_link(comment).click
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author 2"
			fill_in 'Body', with: "Reply Body 2"
			fill_in 'What is', with: @show_page.antispam_solution(comment)
		end

		@show_page.new_comment_submit_button(comment).click

		assert page.has_no_css?('div.error')
		assert page.has_text? "Reply Author 2"
		assert page.has_text? "Reply Body 2"
	end

	test "root comment should fail if spammy" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		# Test leaving a root comment
		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: "wrong answer"
		end

		@show_page.new_comment_submit_button.click

		assert page.has_css?('div.error')
	end

	test "reply should fail if spammy" do
		comment = FactoryGirl.create(:published_comment)
		post = comment.post

		visit bespoke.post_path(post)

		@show_page.comment_reply_link(comment).click
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author 1"
			fill_in 'Body', with: "Reply Body 1"
			fill_in 'What is', with: "wrong answer"
		end

		@show_page.new_comment_submit_button(comment).click

		assert page.has_css?('div.error')
	end

	test "reply forms should be exclusive" do
		comment1 = FactoryGirl.create(:published_comment)
		comment2 = FactoryGirl.create(:published_comment, post: comment1.post)

		visit bespoke.post_path(comment1.post)

		# Check that a form shows up to reply to comment1
		@show_page.comment_reply_link(comment1).click
		assert page.has_css? "form#reply_to_#{comment1.id}_new_comment"

		# Now, without closing that form manually, assert that it is closed
		# automatically when we try to reply to comment2
		@show_page.comment_reply_link(comment2).click
		assert page.has_css? "form#reply_to_#{comment2.id}_new_comment"
		assert page.has_no_css?("form#reply_to_#{comment1.id}_new_comment"),
		       "The form from comment1 should be removed when replying to comment2!"
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

		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		@show_page.comment_edit_link(comment).click
		assert page.has_no_css?("p.comment_author", text: comment.author),
		       "The comment author should have been completely replaced by the edit form!"
		assert page.has_no_css?("div.comment_body", text: comment.body),
		       "The comment body should have been completely replaced by the edit form!"

		within("#edit_comment_#{comment.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Body', with: "Edit Body"
		end
		@show_page.edit_comment_submit_button(comment).click
		assert page.has_css? "p.comment_author", text: "Edit Author"
		assert page.has_css? "div.comment_body", text: "Edit Body"
		assert page.has_no_css?("p.comment_author", text: comment.author),
		       "The old comment author should be gone!"
		assert page.has_no_css?("div.comment_body", text: comment.body),
		       "The old comment body should be gone!"
	end

	test "edit parent comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment)
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent)

		visit bespoke.post_path(parent.post)

		@show_page.comment_edit_link(parent).click
		assert page.has_no_css?("p.comment_author", text: parent.author),
		       "The parent comment author should have been completely replaced by the edit form!"
		assert page.has_no_css?("div.comment_body", text: parent.body),
		       "The parent comment body should have been completely replaced by the edit form!"
		assert page.has_css?("p.comment_author", text: child.author),
		       "The child comment author should still be on the page!"
		assert page.has_css?("div.comment_body", text: child.body),
		       "The child comment body should still be on the page!"

		within("#edit_comment_#{parent.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Body', with: "Edit Body"
		end
		@show_page.edit_comment_submit_button(parent).click
		assert page.has_css?("p.comment_author", text: "Edit Author"),
		       "The parent comment author should now be edited!"
		assert page.has_css?("div.comment_body", text: "Edit Body"),
		       "The parent comment body should now be edited!"
		assert page.has_css?("p.comment_author", text: child.author),
		       "The child comment author should still be on the page!"
		assert page.has_css?("div.comment_body", text: child.body),
		       "The child comment body should still be on the page!"
		assert page.has_no_css?("p.comment_author", text: parent.author),
		       "The old parent comment author should be gone!"
		assert page.has_no_css?("div.comment_body", text: parent.body),
		       "The old parent comment body should be gone!"
	end

	test "edit child comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment)
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent)

		visit bespoke.post_path(parent.post)

		@show_page.comment_edit_link(child).click
		assert page.has_no_css?("p.comment_author", text: child.author),
		       "The child comment author should have been completely replaced by the edit form!"
		assert page.has_no_css?("div.comment_body", text: child.body),
		       "The chid comment body should have been completely replaced by the edit form!"
		assert page.has_css?("p.comment_author", text: parent.author),
		       "The parent comment author should still be on the page!"
		assert page.has_css?("div.comment_body", text: parent.body),
		       "The parent comment body should still be on the page!"

		within("#edit_comment_#{child.id}") do
			fill_in 'Author', with: "Edit Author"
			fill_in 'Body', with: "Edit Body"
		end
		@show_page.edit_comment_submit_button(child).click
		assert page.has_css? "p.comment_author", text: 'Edit Author'
		assert page.has_css? "div.comment_body", text: 'Edit Body'
		assert page.has_css? "p.comment_author", text: parent.author
		assert page.has_css? "div.comment_body", text: parent.body

		assert page.has_no_css?("p.comment_author", text: child.author),
		       "The old child comment author should be gone!"
		assert page.has_no_css?("div.comment_body", text: child.body),
		       "The old child comment body should be gone!"
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

		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		assert page.has_text? comment.author
		assert page.has_text? comment.body

		current_count = Bespoke::Comment.count

		@show_page.comment_delete_link(comment).click
		page.accept_alert

		assert page.has_no_text? comment.author
		assert page.has_no_text? comment.body

		assert(wait_until { Bespoke::Comment.count == current_count - 1 },
		      "Root comment should have been deleted!")
	end

	test "delete parent comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment)
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent)

		visit bespoke.post_path(parent.post)

		assert page.has_text? parent.author
		assert page.has_text? parent.body
		assert page.has_text? child.author
		assert page.has_text? child.body

		current_count = Bespoke::Comment.count

		@show_page.comment_delete_link(parent).click
		page.accept_alert

		assert page.has_no_text?(parent.author), "Parent author should be gone!"
		assert page.has_no_text?(parent.body), "Parent body should be gone!"
		assert page.has_no_text?(child.author), "Child author should be gone!"
		assert page.has_no_text?(child.body), "Child body should be gone!"

		assert(wait_until { Bespoke::Comment.count == current_count - 2 },
		      "Both parent and child should have been deleted!")
	end

	test "delete child comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		parent = FactoryGirl.create(:published_comment)
		child = FactoryGirl.create(:published_comment,
		                           post: parent.post,
		                           parent: parent)

		visit bespoke.post_path(parent.post)

		assert page.has_text? child.author
		assert page.has_text? child.body

		current_count = Bespoke::Comment.count

		@show_page.comment_delete_link(child).click
		page.accept_alert

		assert page.has_no_text?(child.author), "Child author should be gone!"
		assert page.has_no_text?(child.body), "Child body should be gone!"
		assert page.has_text?(parent.author), "Parent author should not be gone!"
		assert page.has_text?(parent.body), "Parent body should not be gone!"

		assert(wait_until { Bespoke::Comment.count == current_count - 1 },
		      "Child comment should have been deleted!")
	end

	test "cancel button should remove errors" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			# Make a mistake-- leave out the body
		end
		@show_page.new_comment_submit_button.click

		# Errors should be on the page
		assert page.has_css?('div.error')

		# Now click cancel
		@show_page.new_comment_cancel_button.click

		# Now errors should be cleared
		assert page.has_no_css?('div.error')
	end
end
