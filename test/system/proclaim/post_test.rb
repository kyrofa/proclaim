require "application_system_test_case"

module Proclaim
	class PostSystemTest < ApplicationSystemTestCase
		include ActionMailer::TestHelper
		include WaitForAjax

		test "index should give option to create new post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.posts_path

			assert page.has_css? "a", text: "New Post"
		end

		test "index should not give option to create new post if not logged in" do
			visit proclaim.posts_path

			assert page.has_no_css? "a", text: "New Post"
		end

		test "index should give option to edit post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_css? "a", text: "Edit"
		end

		test "index should not give option to edit post if not logged in" do
			FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_no_css? "a", text: "Edit"
		end

		test "index should give option to delete post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_css? "a", text: "Delete"
		end

		test "index should not give option to delete post if not logged in" do
			FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_no_css? "a", text: "Delete"
		end

		test "index should show post titles" do
			post1 = FactoryBot.create(:published_post)
			post2 = FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_text? post1.title
			assert page.has_text? post2.title
		end

		test "index should show authors" do
			post1 = FactoryBot.create(:published_post)
			post2 = FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.has_text? post1.author.send(Proclaim.author_name_method)
			assert page.has_text? post2.author.send(Proclaim.author_name_method)
		end

		test "index should show excerpts" do
			post1Body = Faker::Lorem.paragraph(50)

			post1 = FactoryBot.create(:published_post,
									body: post1Body)
			post2 = FactoryBot.create(:published_post,
									body: "foo")

			visit proclaim.posts_path

			post1RenderedBody = page.find("#post_#{post1.id} span.excerpt")
			post2RenderedBody = page.find("#post_#{post2.id} span.excerpt")

			# Make sure the render text from the post is only the excerpt-- no more
			assert_equal post1.excerpt, post1RenderedBody.text
			assert_equal post2.body, post2RenderedBody.text
		end

		test "index should show more link" do
			post1Body = Faker::Lorem.paragraph(50)

			post1 = FactoryBot.create(:published_post,
									body: post1Body)
			post2 = FactoryBot.create(:published_post,
									body: "foo")

			visit proclaim.posts_path

			assert page.has_css?("#post_#{post1.id} a", text: "(more)"),
				"Post 1 should contain a link to view more"
			assert page.has_no_css?("#post_#{post2.id} a", text: "(more)"),
				"Post 2 should not contain a link to see more"
		end

		test "index should show posts ordered by publication date" do
			post1 = FactoryBot.create(:published_post)
			post2 = FactoryBot.create(:published_post)

			visit proclaim.posts_path

			assert page.body.index(post2.title) < page.body.index(post1.title),
				"Post 2 should be shown before post 1!"
		end

		test "index should show drafts ordered by modification date" do
			user = FactoryBot.create(:user)
			sign_in user

			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:post)
			post3 = FactoryBot.create(:post)

			# Update post1 so its updated_at is newest
			post2.body = "Updated Body"
			post2.save

			visit proclaim.posts_path

			assert page.body.index(post2.title) < page.body.index(post3.title),
				"Post 2 draft should be shown before post 3 draft!"
			assert page.body.index(post3.title) < page.body.index(post1.title),
				"Post 3 draft should be shown before post 1 draft!"
		end

		test "index should not show comment count for drafts" do
			user = FactoryBot.create(:user)
			sign_in user

			FactoryBot.create(:comment)

			visit proclaim.posts_path

			assert page.has_no_text? "1 comment"
		end

		test "index should show comment count for published post" do
			user = FactoryBot.create(:user)
			sign_in user

			# Verify no comments
			post = FactoryBot.create(:published_post)
			visit proclaim.posts_path
			assert page.has_text?("No comments"),
				"Comment count should indicate no comments"

			# Verify that single comment count shows up.
			comment = FactoryBot.create(:published_comment, post: post)
			visit proclaim.posts_path
			assert page.has_text?("1 comment"), "Comment count should be shown"

			# Also verify that the comment count is properly pluralized.
			comment = FactoryBot.create(:published_comment, post: comment.post)
			visit proclaim.posts_path
			assert page.has_text?("2 comments"),
				"Comment count should be shown and pluralized"
		end

		test "show should include author name" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)

			assert page.has_text? post.author.send(Proclaim.author_name_method)
		end

		test "show should work via id" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post.id)
			assert page.has_text? post.title
			assert_equal proclaim.post_path(post.friendly_id), current_path,
						"Post show via ID should redirect to more friendly URL"
		end

		test "show should work via slug" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post.friendly_id)
			assert page.has_text? post.title
		end

		test "show should work via old slugs for published posts" do
			post = FactoryBot.create(:published_post, title: "New Post")
			old_slug = post.friendly_id

			# Change slug
			post.title = "New Post Modified"
			post.save

			visit proclaim.post_path(old_slug)
			assert page.has_text? post.title
			assert_equal proclaim.post_path(post.friendly_id), current_path,
						"Post show via ID should redirect to more friendly URL"
		end

		test "should create post" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_post_path

			edit_page = EditPage.new
			edit_page.set_title("Post Title")
			edit_page.set_body("Paragraph 1\nParagraph 2")

			assert_difference('Proclaim::Post.count', 1,
							  "A post should have been created") do
				click_button "Create"
				assert page.has_text?("Post Title"), "Post title should be shown"
				assert page.has_text?("Paragraph 1\nParagraph 2"),
					   "Post body should be shown"
			end
		end

		test "form should not replace non-alphanumeric text in title with HTML entities" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_post_path

			edit_page = EditPage.new
			edit_page.set_title("\"quotes\"")
			# Don't fill in body

			click_button "Create"

			assert page.has_css? "div#error_explanation"

			assert page.has_text?("\"quotes\""), "Form should still be showing quotes in title!"
			assert page.has_no_text?("&quot;quotes&quot;"), "Form should not be showing HTML entities in title!"
		end

		test "show should not replace non-alphanumeric text in title with HTML entities" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_post_path

			edit_page = EditPage.new
			edit_page.set_title("\"quotes\"")
			edit_page.set_body("Paragraph 1\nParagraph 2")

			click_button "Create"

			assert page.has_text?("\"quotes\""), "Show page should be showing quotes in title!"
			assert page.has_no_text?("&quot;quotes&quot;"), "Show page should not be showing HTML entities in title!"
		end

		test "new should show error without title" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_post_path

			edit_page = EditPage.new
			edit_page.set_body("Paragraph 1\nParagraph 2")
			# Don't fill in title

			assert_no_difference('Proclaim::Post.count',
								 "No post should have been created without a title") do
				click_button "Create"
				assert page.has_css?("div#error_explanation"),
					   "Should show error complaining about lack of title"
			end
		end

		test "new should show error without body" do
			user = FactoryBot.create(:user)
			sign_in user

			visit proclaim.new_post_path

			edit_page = EditPage.new
			edit_page.set_title("Post Title")
			# Don't fill in body

			assert_no_difference('Proclaim::Post.count') do
				click_button "Create"
				assert page.has_css? "div#error_explanation"
			end
		end

		test "show should include edit/delete buttons if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)

			assert page.has_css?('a', text: "Edit"),
				   "The show page should include a link to edit if logged in!"
			assert page.has_css?('a', text: "Delete"),
				   "The show page should include a link to delete if logged in!"
		end

		test "show should not include edit/delete buttons if not logged in" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)

			assert page.has_no_css?('a', text: "Edit"),
				   "The show page should not include a link to edit if not logged in!"
			assert page.has_no_css?('a', text: "Delete"),
				   "The show page should not include a link to delete if not logged in!"
		end

		test "should be able to create new root comment with subscription while logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)
			show_page = ShowPage.new

			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: show_page.antispam_solution
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			# Verify that email field is shown
			assert page.has_text?('Email')

			assert_difference('Proclaim::Subscription.count', 1, "A new subscription should have been added!") do
				show_page.new_comment_submit_button.click
				wait_for_ajax
			end

			# Now email field should be hidden
			assert page.has_no_text?('Email'),
				   "Email field should be hidden again when form is successful"

			post.reload # Refresh post to pull in new associations

			assert 1, post.subscriptions.count
			assert_equal "example@example.com", post.subscriptions.first.email
		end

		test "should be able to create new root comment with subscription while not logged in" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)
			show_page = ShowPage.new

			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: show_page.antispam_solution
				check 'Notify me'
				fill_in 'Email', with: "example@example.com"
			end

			assert_difference('Proclaim::Subscription.count', 1, "A new subscription should have been added!") do
				show_page.new_comment_submit_button.click
				wait_for_ajax
			end

			post.reload # Refresh post to pull in new associations

			assert 1, post.subscriptions.count
			assert_equal "example@example.com", post.subscriptions.first.email
		end

		test "should be able to create new reply with subscription while logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			comment = FactoryBot.create(:published_comment)

			visit proclaim.post_path(comment.post)
			show_page = ShowPage.new

			click_link "Reply"
			within("#reply_to_#{comment.id}_new_comment") do
				fill_in 'Author', with: "Reply Author"
				fill_in 'Body', with: "Reply Body"
				fill_in 'What is', with: show_page.antispam_solution(comment)
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			assert_difference('Proclaim::Subscription.count', 1, "A new subscription should have been added!") do
				show_page.new_comment_submit_button(comment).click
				wait_for_ajax
			end

			comment.reload # Refresh comment to pull in new associations

			assert 1, comment.post.subscriptions.count
			assert_equal "example@example.com", comment.post.subscriptions.first.email
		end

		test "should be able to create new reply with subscription while not logged in" do
			comment = FactoryBot.create(:published_comment)

			visit proclaim.post_path(comment.post)
			show_page = ShowPage.new

			click_link "Reply"
			within("#reply_to_#{comment.id}_new_comment") do
				fill_in 'Author', with: "Reply Author"
				fill_in 'Body', with: "Reply Body"
				fill_in 'What is', with: show_page.antispam_solution(comment)
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			assert_difference('Proclaim::Subscription.count', 1, "A new subscription should have been added!") do
				show_page.new_comment_submit_button(comment).click
				wait_for_ajax
			end

			comment.reload # Refresh comment to pull in new associations

			assert 1, comment.post.subscriptions.count
			assert_equal "example@example.com", comment.post.subscriptions.first.email
		end

		test "should not send new comment notification email containing own comment" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)
			show_page = ShowPage.new

			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: show_page.antispam_solution
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			# Make sure only a single email was sent
			assert_enqueued_emails 1 do
				assert_difference('Proclaim::Subscription.count', 1, "A new subscription should have been added!") do
					show_page.new_comment_submit_button.click
					wait_for_ajax
				end
			end
		end

		test "should not create new root comment with subscription if spammy" do
			comment = FactoryBot.create(:published_comment)

			visit proclaim.post_path(comment.post)
			show_page = ShowPage.new

			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: "wrong answer"
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			assert_no_difference('Proclaim::Comment.count',
								 "A new comment should not have been added!") do
				assert_no_difference('Proclaim::Subscription.count',
									  "A new subscription should not have been added!") do
					show_page.new_comment_submit_button.click
					assert page.has_css?('div.error'), "Failed antispam question-- errors should show!"
				end
			end
		end

		test "should not create new reply with subscription if spammy" do
			comment = FactoryBot.create(:published_comment)

			visit proclaim.post_path(comment.post)
			show_page = ShowPage.new

			click_link "Reply"
			within("#reply_to_#{comment.id}_new_comment") do
				fill_in 'Author', with: "Reply Author"
				fill_in 'Body', with: "Reply Body"
				fill_in 'What is', with: "wrong answer"
				check 'Notify me of other comments on this post'
				fill_in 'Email', with: "example@example.com"
			end

			assert_no_difference('Proclaim::Comment.count',
								 "A new comment should not have been added!") do
				assert_no_difference('Proclaim::Subscription.count',
									  "A new subscription should not have been added!") do
					show_page.new_comment_submit_button(comment).click
					assert page.has_css?('div.error'), "Failed antispam question-- errors should show!"
				end
			end
		end

		test "catch lack of email address" do
			post = FactoryBot.create(:published_post)
			visit proclaim.post_path(post)
			show_page = ShowPage.new

			# Create a new comment and say "notify me," but don't provide email
			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: show_page.antispam_solution
				check 'Notify me of other comments on this post'
			end

			assert_no_difference('Proclaim::Comment.count',
								 "A new comment should not have been added!") do
				assert_no_difference('Proclaim::Subscription.count',
									  "A new subscription should not have been added!") do
					show_page.new_comment_submit_button.click
					assert page.has_css?('div.error')
				end
			end
		end

		test "cancel button should remove email field" do
			post = FactoryBot.create(:published_post)

			visit proclaim.post_path(post)
			show_page = ShowPage.new

			within('#new_comment') do
				fill_in 'Author', with: "Comment Author"
				fill_in 'Body', with: "Comment Body"
				fill_in 'What is', with: show_page.antispam_solution
				check 'Notify me of other comments on this post'
			end

			# Verify email field is shown
			assert page.has_text?('Email')

			# Now click cancel
			show_page.new_comment_cancel_button.click

			# Now email field should be hidden
			assert page.has_no_text?('Email')
		end
	end
end
