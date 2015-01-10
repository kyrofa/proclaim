require 'test_helper'

class PostTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)

		@edit_page = EditPage.new
	end

	test "index should give option to create new post if logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		visit proclaim.posts_path

		assert page.has_css? "a", text: "New Post"
	end

	test "index should not give option to create new post if not logged in" do
		visit proclaim.posts_path

		assert page.has_no_css? "a", text: "New Post"
	end

	test "index should give option to edit post if logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_css? "a", text: "Edit"
	end

	test "index should not give option to edit post if not logged in" do
		post = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_no_css? "a", text: "Edit"
	end

	test "index should give option to delete post if logged in" do
		user = FactoryGirl.create(:user)
		sign_in user

		post = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_css? "a", text: "Delete"
	end

	test "index should not give option to delete post if not logged in" do
		post = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_no_css? "a", text: "Delete"
	end

	test "index should show post titles" do
		post1 = FactoryGirl.create(:published_post)
		post2 = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_text? post1.title
		assert page.has_text? post2.title
	end

	test "index should show authors" do
		post1 = FactoryGirl.create(:published_post)
		post2 = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.has_text? post1.author.send(Proclaim.author_name_method)
		assert page.has_text? post2.author.send(Proclaim.author_name_method)
	end

	test "index should show excerpts" do
		post1Body = Faker::Lorem.paragraph(50)

		post1 = FactoryGirl.create(:published_post,
		                           body: post1Body)
		post2 = FactoryGirl.create(:published_post,
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

		post1 = FactoryGirl.create(:published_post,
		                           body: post1Body)
		post2 = FactoryGirl.create(:published_post,
		                           body: "foo")

		visit proclaim.posts_path

		assert page.has_css?("#post_#{post1.id} a", text: "(more)"),
		       "Post 1 should contain a link to view more"
		assert page.has_no_css?("#post_#{post2.id} a", text: "(more)"),
		       "Post 2 should not contain a link to see more"
	end

	test "index should show posts ordered by publication date" do
		post1 = FactoryGirl.create(:published_post)
		post2 = FactoryGirl.create(:published_post)

		visit proclaim.posts_path

		assert page.body.index(post2.title) < page.body.index(post1.title),
		       "Post 2 should be shown before post 1!"
	end

	test "index should show drafts ordered by modification date" do
		user = FactoryGirl.create(:user)
		sign_in user

		post1 = FactoryGirl.create(:post)
		post2 = FactoryGirl.create(:post)
		post3 = FactoryGirl.create(:post)

		# Update post1 so its updated_at is newest
		post2.body = "Updated Body"
		post2.save

		visit proclaim.posts_path

		assert page.body.index(post2.title) < page.body.index(post3.title),
		       "Post 2 draft should be shown before post 3 draft!"
		assert page.body.index(post3.title) < page.body.index(post1.title),
		       "Post 3 draft should be shown before post 1 draft!"
	end

	test "show should show author name" do
		post = FactoryGirl.create(:published_post)

		visit proclaim.post_path(post)

		assert page.has_text? post.author.send(Proclaim.author_name_method)
	end

	test "image should have relative source path" do
		user = FactoryGirl.create(:user)
		sign_in user

		image = FactoryGirl.create(:image)
		image.post.body = @edit_page.medium_inserted_image_html(image)
		image.post.save

		image_tags = Nokogiri::HTML.fragment(image.post.body).css("img")

		assert_equal 1, image_tags.length
		refute_match root_url, image_tags[0].attribute("src"),
		             "Images should have relative paths"
	end
end
