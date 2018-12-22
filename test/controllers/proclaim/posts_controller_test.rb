require 'test_helper'

module Proclaim
	class PostsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
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

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_includes assigns(:posts), post1
			assert_includes assigns(:posts), post2
		end

		test "should get index even if not logged in" do
			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:published_post)

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_not_includes assigns(:posts), post1
			assert_includes assigns(:posts), post2
		end

		test "posts should be ordered by publication date" do
			post1 = FactoryBot.create(:published_post)
			post2 = FactoryBot.create(:published_post)

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_equal 2, assigns(:posts).count
			assert_equal post2, assigns(:posts).first
			assert_equal post1, assigns(:posts).last
		end

		test "drafts should be ordered by updated date" do
			user = FactoryBot.create(:user)
			sign_in user

			post1 = FactoryBot.create(:post)
			post2 = FactoryBot.create(:post)
			post3 = FactoryBot.create(:post)

			# Update post1 so its updated_at is newest
			post2.body = "Updated Body"
			post2.save

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_equal 3, assigns(:posts).count
			assert_equal post2, assigns(:posts).first
			assert_equal post3, assigns(:posts).second
			assert_equal post1, assigns(:posts).last
		end

		test "should get new if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			get :new
			assert_response :success
		end

		test "should not get new if not logged in" do
			get :new
			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should create post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_difference('Post.count') do
				post :create, post: {
					author_id: newPost.author_id,
					body: newPost.body,
					title: newPost.title
				}
			end

			assert_redirected_to post_path(assigns(:post))
			assert_match /successfully created/, flash[:notice]
			refute assigns(:post).published?
		end

		test "should create published post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_difference('Post.count') do
				post :create, post: {
					author_id: newPost.author_id,
					body: newPost.body,
					title: newPost.title
				}, publish: "true"
			end

			assert_redirected_to post_path(assigns(:post))
			assert_match  /successfully created/, flash[:notice]
			assert assigns(:post).published?
		end

		test "should not create post without title" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_no_difference('Post.count') do
				post :create, post: {
					author_id: newPost.author_id,
					body: newPost.body
					# Leave off title
				}
			end

			assert assigns(:post).errors.any?,
			       "Expected an error due to lack of post title"
			assert_template :new, "Expected new view to be rendered again"
		end

		test "should not create post without body" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)

			assert_no_difference('Post.count') do
				post :create, post: {
					author_id: newPost.author_id,
					title: newPost.title
					# Leave off body
				}
			end

			assert assigns(:post).errors.any?,
			       "Expected an error due to lack of post body"
			assert_template :new, "Expected new view to be rendered again"
		end

		test "should upload images when creating post" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.build(:post)
			image = FactoryBot.build(:image, post: newPost)

			newPost.body = "<img src=\"#{image.image.url}\"></img>"

			post :create, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			post = Post.first # This works since there's only one
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
				post :create, post: {
					author_id: newPost.author_id,
					body: newPost.body,
					title: newPost.title
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

			get :show, id: newPost
			assert_response :success
			assert_equal newPost, assigns(:post)
		end

		test "should show published post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			# Should show published post
			newPost = FactoryBot.create(:published_post)

			get :show, id: newPost
			assert_response :success
			assert_equal newPost, assigns(:post)
		end

		test "should not show draft post if not logged in" do
			# Should not show draft post
			newPost = FactoryBot.create(:post)

			# Controller should hide the "permission denied" in a "not-found"
			assert_raises ActiveRecord::RecordNotFound do
				get :show, id: newPost
			end
		end

		test "should show published post if not logged in" do
			# Should show published post
			newPost = FactoryBot.create(:published_post)

			get :show, id: newPost
			assert_response :success
			assert_equal newPost, assigns(:post)
		end

		test "should show post via id" do
			post = FactoryBot.create(:published_post, title: "New Post")

			# Test with ID
			get :show, id: post.id
			assert_response :redirect,
			                "Visiting a post by ID should redirect to slug"
			assert_equal post, assigns(:post)
		end

		test "should show post via slug" do
			post = FactoryBot.create(:published_post, title: "New Post")

			# Test with slug
			get :show, id: post.friendly_id
			assert_response :success
			assert_equal post, assigns(:post)
		end

		test "should not show draft post via old slugs" do
			user = FactoryBot.create(:user)
			sign_in user

			post = FactoryBot.create(:post, title: "New Post")
			old_slug = post.friendly_id

			# Now change slug
			post.title = "New Post Modified"
			post.save

			# Verify that old slug doesn't work
			assert_raises ActiveRecord::RecordNotFound,
			              "Draft posts should not maintain slug history" do
				get :show, id: old_slug
			end
		end

		test "should show published post via old slugs" do
			post = FactoryBot.create(:published_post, title: "New Post")
			old_slug = post.friendly_id

			# Now change slug
			post.title = "New Post Modified"
			post.save

			# Verify that old slug still works
			get :show, id: old_slug
			assert_response :redirect, "This should redirect to the current slug"
			assert_equal assigns(:post), post
		end

		test "should get edit if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			get :edit, id: newPost
			assert_response :success
			assert_equal assigns(:post), newPost
		end

		test "should not get edit if not logged in" do
			newPost = FactoryBot.create(:post)

			get :edit, id: newPost
			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should update post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			assert_redirected_to post_path(assigns(:post))
			assert_match /successfully updated/, flash[:notice]
			refute assigns(:post).published?
		end

		test "should publish post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}, publish: "true"

			assert_redirected_to post_path(assigns(:post))
			assert_match /successfully updated/, flash[:notice]
			assert assigns(:post).published?, "Post should now be published!"
		end

		test "should upload images when updating a post" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)
			image = FactoryBot.build(:image, post: newPost)

			newPost.body = "<img src=\"#{image.image.url}\">"

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			post = Post.first # This works since there's only one
			assert_equal 1, post.images.count, "The post should have an image"

			image = post.images.first

			save_path = File.join(Rails.public_path, image.image.store_dir)
			saved_file_path = File.join(save_path, image.image_identifier)
			assert File.exist?(saved_file_path), "File should be saved: #{saved_file_path}"

			document = Nokogiri::HTML.fragment(post.body)
			image_tags = document.css("img")
			assert_equal 1, image_tags.count,
			             "Post body should contain one image tag"

			# Note that, now that the image is saved, this URL is different than
			# the one submitted to :create
			assert_equal image.image.url, image_tags.first.attributes["src"].value
		end

		test "should not update post if not logged in" do
			newPost = FactoryBot.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should not update post without title" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				title: "" # Remove title
			}

			assert assigns(:post).errors.any?,
			       "Expected an error due to lack of post title"
			assert_template :edit, "Expected edit view to be rendered again"
		end

		test "should not update post without body" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: "" # Remove body
			}

			assert assigns(:post).errors.any?,
			       "Expected an error due to lack of post body"
			assert_template :edit, "Expected edit view to be rendered again"
		end

		test "should destroy post if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newPost = FactoryBot.create(:post)

			assert_difference('Post.count', -1) do
				delete :destroy, id: newPost
			end

			assert_redirected_to posts_path
			assert_match /successfully destroyed/, flash[:notice]
		end

		test "should not destroy post if not logged in" do
			newPost = FactoryBot.create(:post)

			assert_no_difference('Post.count') do
				delete :destroy, id: newPost
			end

			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end
  end
end
