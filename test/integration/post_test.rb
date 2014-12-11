require 'test_helper'

class PostTest < ActionDispatch::IntegrationTest
	setup do
		ApplicationController.any_instance.stubs(:current_user).returns(nil)
		ApplicationController.any_instance.stubs(:authenticate_user).returns(false)
	end

	test "index should show post titles" do
		post1 = FactoryGirl.create(:published_post)
		post2 = FactoryGirl.create(:published_post)

		visit bespoke.posts_path

		assert page.has_text? post1.title
		assert page.has_text? post2.title
	end

	test "index should show authors" do
		post1 = FactoryGirl.create(:published_post)
		post2 = FactoryGirl.create(:published_post)

		visit bespoke.posts_path

		assert page.has_text? post1.author.send(Bespoke.author_name_method)
		assert page.has_text? post2.author.send(Bespoke.author_name_method)
	end

	test "index should show excerpts" do
		post1Body = Faker::Lorem.paragraph(50)

		post1 = FactoryGirl.create(:published_post,
		                           body: post1Body)
		post2 = FactoryGirl.create(:published_post,
		                           body: "foo")

		visit bespoke.posts_path

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

		visit bespoke.posts_path

		assert page.has_css?("#post_#{post1.id} a", text: "(more)"),
		       "Post 1 should contain a link to view more"
		assert page.has_no_css?("#post_#{post2.id} a", text: "(more)"),
		       "Post 2 should not contain a link to see more"
	end

	test "show should show author name" do
		post = FactoryGirl.create(:published_post)

		visit bespoke.post_path(post)

		assert page.has_text? post.author.send(Bespoke.author_name_method)
	end
end
