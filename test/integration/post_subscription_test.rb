require 'test_helper'

class PostSubscriptionTest < ActionDispatch::IntegrationTest
	self.use_transactional_fixtures = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium

		ActionMailer::Base.deliveries.clear
	end

	teardown do
		DatabaseCleaner.clean
		Capybara.use_default_driver
	end

	test "should be able to create new root comment with subscription while logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			fill_in 'Body', with: "Comment Body"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find('#new_comment input[type=submit]').click
			assert page.has_css?('h3', text: 'Comment Title')
		end

		# Make sure a welcome email was sent
		assert_equal ["example@example.com"], ActionMailer::Base.deliveries.last.to

		post.reload # Refresh post to pull in new associations

		assert 1, post.subscriptions.count
		assert_equal "example@example.com", post.subscriptions.first.email
	end

	test "should be able to create new root comment with subscription while not logged in" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			fill_in 'Body', with: "Comment Body"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find('#new_comment input[type=submit]').click
			assert page.has_css?('h3', text: 'Comment Title')
		end

		# Make sure a welcome email was sent
		assert_equal ["example@example.com"], ActionMailer::Base.deliveries.last.to

		post.reload # Refresh post to pull in new associations

		assert 1, post.subscriptions.count
		assert_equal "example@example.com", post.subscriptions.first.email
	end

	test "should be able to create new reply with subscription while logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		click_link "Reply"
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author"
			fill_in 'Title', with: "Reply Title"
			fill_in 'Body', with: "Reply Body"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find("#reply_to_#{comment.id}_new_comment input[type=submit]").click
			assert page.has_css?('h3', text: 'Reply Title')
		end

		# Make sure a welcome email was sent
		assert_equal ["example@example.com"], ActionMailer::Base.deliveries.last.to

		comment.reload # Refresh comment to pull in new associations

		assert 1, comment.post.subscriptions.count
		assert_equal "example@example.com", comment.post.subscriptions.first.email
	end

	test "should be able to create new reply with subscription while not logged in" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		click_link "Reply"
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author"
			fill_in 'Title', with: "Reply Title"
			fill_in 'Body', with: "Reply Body"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count') do
			find("#reply_to_#{comment.id}_new_comment input[type=submit]").click
			assert page.has_css?('h3', text: 'Reply Title')
		end

		# Make sure a welcome email was sent
		assert_equal ["example@example.com"], ActionMailer::Base.deliveries.last.to

		comment.reload # Refresh comment to pull in new associations

		assert 1, comment.post.subscriptions.count
		assert_equal "example@example.com", comment.post.subscriptions.first.email
	end

	test "catch lack of email address" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		# Create a new comment and say "notify me," but don't provide email
		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			fill_in 'Body', with: "Comment Body"
			check 'Notify me of other comments on this post'
		end

		assert_no_difference('Bespoke::Comment.count') do
			assert_no_difference('Bespoke::Subscription.count') do
				find('#new_comment input[type=submit]').click
				assert page.has_css?('div.error')
			end
		end

		# Make sure no email was sent
		assert_empty ActionMailer::Base.deliveries
	end

	test "catch bad email address" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		# Create a new comment and say "notify me," but provide invalid email
		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Title', with: "Comment Title"
			fill_in 'Body', with: "Comment Body"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "bad_email"
		end

		assert_no_difference('Bespoke::Comment.count') do
			assert_no_difference('Bespoke::Subscription.count') do
				find('#new_comment input[type=submit]').click
				assert page.has_css?('div.error')
			end
		end

		# Make sure no email was sent
		assert_empty ActionMailer::Base.deliveries
	end
end
