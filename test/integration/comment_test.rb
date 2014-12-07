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
		post = FactoryGirl.create(:post,
		                          published: true,
		                          publication_date: Date.today)

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
		post = FactoryGirl.create(:post,
		                          published: true,
		                          publication_date: Date.today)
		comment = FactoryGirl.create(:comment,
		                             post: post,
		                             title: "Comment Title")

		visit bespoke.post_path(post)

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

	test "delete root comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:post,
		                          published: true,
		                          publication_date: Date.today)
		comment = FactoryGirl.create(:comment,
		                             post: post,
		                             title: "Comment Title")

		visit bespoke.post_path(post)

		assert_difference('Bespoke::Comment.count', -1) do
			find("#comment_#{comment.id} .delete").click
			page.accept_alert
			assert page.has_no_css?('h3', text: 'Comment Title')
		end
	end

	test "delete parent comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:post,
		                          published: true,
		                          publication_date: Date.today)
		parent = FactoryGirl.create(:comment,
		                             post: post,
		                             title: "Parent Title")
		child = FactoryGirl.create(:comment,
		                             post: post,
		                             parent: parent,
		                             title: "Child Title")

		visit bespoke.post_path(post)

		assert_difference('Bespoke::Comment.count', -2) do
			find("#comment_#{parent.id} .delete").click
			page.accept_alert
			assert page.has_no_css?('h3', text: 'Parent Title')
			assert page.has_no_css?('h3', text: 'Child Title')
		end
	end

	test "delete child comment" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:post,
		                          published: true,
		                          publication_date: Date.today)
		parent = FactoryGirl.create(:comment,
		                             post: post)
		child = FactoryGirl.create(:comment,
		                             post: post,
		                             parent: parent,
		                             title: "Child Title")

		visit bespoke.post_path(post)

		assert_difference('Bespoke::Comment.count', -1) do
			find("#comment_#{child.id} .delete").click
			page.accept_alert
			assert page.has_no_css?('h3', text: 'Child Title')
		end
	end
end
