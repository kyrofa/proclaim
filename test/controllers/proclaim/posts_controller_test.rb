require 'test_helper'

module Proclaim
	class PostsControllerTest < ActionDispatch::IntegrationTest
		include Engine.routes.url_helpers

		setup do
			# By default, no one is logged in
			sign_in nil
		end

		teardown do
			image = Image.new
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.cache_dir))
			FileUtils.rm_rf(File.join(Rails.public_path, image.image.store_dir))
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
			assert_match /not authorized/, flash[:error]
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
						title: newPost.title
					}
				}
			end

			assert_redirected_to post_path(Post.last)
			assert_match /successfully created/, flash[:notice]
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
						title: newPost.title
					}, publish: "true"
				}
			end

			assert_redirected_to post_path(Post.last)
			assert_match /successfully created/, flash[:notice]
			assert Post.last.published?
		end

		test "should upload images when creating post" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)
			image = FactoryBot.build(:image, post: newPost)

			newPost.body = "<img src=\"#{image.image.url}\"></img>"

			post posts_url, params: {
				post: {
					author_id: newPost.author_id,
					body: newPost.body,
					title: newPost.title
				}
			}

			post = Post.last
			assert_equal 1, post.images.count, "The post should have an image"

			image = post.images.first

			save_path = File.join(Rails.public_path, image.image.store_dir)
			saved_file_path = File.join(save_path, image.image_identifier)
			assert File.exist?(saved_file_path), "File should be saved: #{saved_file_path}"

			document = Nokogiri::HTML.fragment(post.body)
			image_tags = document.css("img")
			assert_equal 1, image_tags.count, "Post body should have one image tag"

			# Note that, now that the image is saved, this URL is different than
			# the one submitted to :create
			assert_equal image.image.url, image_tags.first.attributes["src"].value
		end

		test "should not create post if not logged in" do
			newPost = FactoryBot.build(:post)

			assert_no_difference('Post.count') do
				post posts_url, params: {
					post: {
						author_id: newPost.author_id,
						body: newPost.body,
						title: newPost.title
					}
				}
			end

			assert_response :redirect
			assert_match /not authorized/, flash[:error]
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
