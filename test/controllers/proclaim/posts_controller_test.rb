require 'test_helper'

module Proclaim
	class PostsControllerTest < ActionDispatch::IntegrationTest
		include Engine.routes.url_helpers

		setup do
			# By default, no one is logged in
			sign_in nil
		end

		test "should get index if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:published_post)

			get posts_url
			assert_response :success
			assert_match post1.title, @response.body
			assert_match post2.title, @response.body
		end

		test "should get index even if not logged in" do
			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:published_post)

			get posts_url
			assert_response :success
			refute_match post1.title, @response.body
			assert_match post2.title, @response.body
		end

		test "posts should be displayed by publication date" do
			post1 = FactoryBot.create(:published_post)
			post2 = FactoryBot.create(:published_post)

			get posts_url
			assert_response :success
			post1_index = @response.body.index(post1.title)
			post2_index = @response.body.index(post2.title)
			assert post2_index < post1_index
		end

		test "drafts should be displayed by updated date" do
			user = FactoryBot.create(:user)
			sign_in user

			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:post)
			post3 = FactoryBot.create(:post)

			# Update post1 so its updated_at is newest
			post2.body = "Updated Body"
			post2.save

			get posts_url
			assert_response :success

			post1_index = @response.body.index(post1.title)
			post2_index = @response.body.index(post2.title)
			post3_index = @response.body.index(post3.title)
			assert post2_index < post1_index
			assert post2_index < post3_index
			assert post3_index < post1_index
	end

		test "should get new if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			get new_post_url
			assert_response :success
		end

		test "should not get new if not logged in" do
			get new_post_url
			assert_response :redirect
			assert_match(/not authorized/, flash[:error])
		end

		test "should create post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_difference('Post.count') do
				post posts_url, params: {
					post: {
						author_id: newPost.author_id,
						body: newPost.body,
						quill_body: newPost.quill_body,
						title: newPost.title,
						subtitle: newPost.subtitle,
					}
				}
			end

			assert_redirected_to post_path(Post.last)
			assert_match(/successfully created/, flash[:notice])
			refute Post.last.published?
		end

		test "should create published post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_difference('Post.count') do
				post posts_url, params: {
					post: {
						author_id: newPost.author_id,
						body: newPost.body,
						quill_body: newPost.quill_body,
						title: newPost.title,
						subtitle: newPost.subtitle,
					}, publish: "true"
				}
			end

			assert_redirected_to post_path(Post.last)
			assert_match(/successfully created/, flash[:notice])
			assert Post.last.published?
		end

		test "should not create post if not logged in" do
			newPost = FactoryBot.build(:post)

			assert_no_difference('Post.count') do
				post posts_url, params: {
					post: {
						author_id: newPost.author_id,
						body: newPost.body,
						quill_body: newPost.quill_body,
						title: newPost.title,
						subtitle: newPost.subtitle,
					}
				}
			end

			assert_response :redirect
			assert_match(/not authorized/, flash[:error])
		end

		test "should show draft post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			# Should show draft post
			newPost = FactoryBot.create(:post)

			get post_url(newPost)
			assert_response :success
			assert_match newPost.title, @response.body
			assert_match newPost.body, @response.body
		end

		test "should show published post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			# Should show published post
			newPost = FactoryBot.create(:published_post)

			get post_url(newPost)
			assert_response :success
			assert_match newPost.title, @response.body
			assert_match newPost.body, @response.body
		end

		test "should not show draft post if not logged in" do
			# Should not show draft post
			newPost = FactoryBot.create(:post)

			# Controller should hide the "permission denied" in a "not-found"
			assert_raises ActiveRecord::RecordNotFound do
				get post_url(newPost)
			end
		end
	end
end
