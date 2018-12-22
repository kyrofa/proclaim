require "test_helper"

class PostsTest < ApplicationSystemTestCase
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		@edit_page = EditPage.new
	end

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

		post = FactoryBot.create(:published_post)

		visit proclaim.posts_path

		assert page.has_css? "a", text: "Edit"
	end

	test "index should not give option to edit post if not logged in" do
		post = FactoryBot.create(:published_post)

		visit proclaim.posts_path

		assert page.has_no_css? "a", text: "Edit"
	end

	test "index should give option to delete post if logged in" do
		user = FactoryBot.create(:user)
		sign_in user

		post = FactoryBot.create(:published_post)

		visit proclaim.posts_path

		assert page.has_css? "a", text: "Delete"
	end

	test "index should not give option to delete post if not logged in" do
		post = FactoryBot.create(:published_post)

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

		comment = FactoryBot.create(:comment)

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

	test "image should have relative source path" do
		user = FactoryBot.create(:user)
		sign_in user

		image = FactoryBot.create(:image)
		image.post.body = @edit_page.medium_inserted_image_html(image)
		image.post.save

		image_tags = Nokogiri::HTML.fragment(image.post.body).css("img")

		assert_equal 1, image_tags.length,
		             "Post body should contain one image tag"
		refute_match root_url, image_tags[0].attribute("src"),
		             "Images should have relative paths"
	end
end
