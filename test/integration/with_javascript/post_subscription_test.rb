require 'test_helper'

class PostSubscriptionTest < ActionDispatch::IntegrationTest
	include WaitForAjax
	self.use_transactional_fixtures = false

	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		DatabaseCleaner.strategy = :truncation
		DatabaseCleaner.start

		Capybara.current_driver = :selenium

		ActionMailer::Base.deliveries.clear

		@show_page = ShowPage.new
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
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count', 1, "A new subscription should have been added!") do
			@show_page.new_comment_submit_button.click
			wait_for_ajax
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
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count', 1, "A new subscription should have been added!") do
			@show_page.new_comment_submit_button.click
			wait_for_ajax
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
			fill_in 'Body', with: "Reply Body"
			fill_in 'What is', with: @show_page.antispam_solution(comment)
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count', 1, "A new subscription should have been added!") do
			@show_page.new_comment_submit_button(comment).click
			wait_for_ajax
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
			fill_in 'Body', with: "Reply Body"
			fill_in 'What is', with: @show_page.antispam_solution(comment)
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count', 1, "A new subscription should have been added!") do
			@show_page.new_comment_submit_button(comment).click
			wait_for_ajax
		end

		# Make sure a welcome email was sent
		assert_equal ["example@example.com"], ActionMailer::Base.deliveries.last.to

		comment.reload # Refresh comment to pull in new associations

		assert 1, comment.post.subscriptions.count
		assert_equal "example@example.com", comment.post.subscriptions.first.email
	end

	test "should not send new comment notification email containing own comment" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_difference('Bespoke::Subscription.count', 1, "A new subscription should have been added!") do
			@show_page.new_comment_submit_button.click
			wait_for_ajax
		end

		# Make sure only a single email was sent
		assert_equal 1, ActionMailer::Base.deliveries.count,
		             "Only a welcome email should have been sent!"
		assert_match "Welcome", ActionMailer::Base.deliveries.last.subject
	end

	test "should not create new root comment with subscription if spammy" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: "wrong answer"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_no_difference('Bespoke::Comment.count',
		                     "A new comment should not have been added!") do
			assert_no_difference('Bespoke::Subscription.count',
				                  "A new subscription should not have been added!") do
				@show_page.new_comment_submit_button.click
				assert page.has_css?('div.error'), "Failed antispam question-- errors should show!"
				wait_for_ajax
			end
		end

		# Make sure no email was sent
		assert_empty ActionMailer::Base.deliveries
	end

	test "should not create new reply with subscription if spammy" do
		comment = FactoryGirl.create(:published_comment)

		visit bespoke.post_path(comment.post)

		click_link "Reply"
		within("#reply_to_#{comment.id}_new_comment") do
			fill_in 'Author', with: "Reply Author"
			fill_in 'Body', with: "Reply Body"
			fill_in 'What is', with: "wrong answer"
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "example@example.com"
		end

		assert_no_difference('Bespoke::Comment.count',
		                     "A new comment should not have been added!") do
			assert_no_difference('Bespoke::Subscription.count',
				                  "A new subscription should not have been added!") do
				@show_page.new_comment_submit_button(comment).click
				assert page.has_css?('div.error'), "Failed antispam question-- errors should show!"
				wait_for_ajax
			end
		end

		# Make sure no email was sent
		assert_empty ActionMailer::Base.deliveries
	end

	test "catch lack of email address" do
		post = FactoryGirl.create(:published_post)
		visit bespoke.post_path(post)

		# Create a new comment and say "notify me," but don't provide email
		within('#new_comment') do
			fill_in 'Author', with: "Comment Author"
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
			check 'Notify me of other comments on this post'
		end

		assert_no_difference('Bespoke::Comment.count',
		                     "A new comment should not have been added!") do
			assert_no_difference('Bespoke::Subscription.count',
				                  "A new subscription should not have been added!") do
				@show_page.new_comment_submit_button.click
				assert page.has_css?('div.error')
				wait_for_ajax
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
			fill_in 'Body', with: "Comment Body"
			fill_in 'What is', with: @show_page.antispam_solution
			check 'Notify me of other comments on this post'
			fill_in 'Email', with: "bad_email"
		end

		assert_no_difference('Bespoke::Comment.count',
		                     "A new comment should not have been added!") do
			assert_no_difference('Bespoke::Subscription.count',
				                  "A new subscription should not have been added!") do
				@show_page.new_comment_submit_button.click
				assert page.has_css?('div.error')
				wait_for_ajax
			end
		end

		# Make sure no email was sent
		assert_empty ActionMailer::Base.deliveries
	end
end
