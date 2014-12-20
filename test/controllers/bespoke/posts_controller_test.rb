require 'test_helper'

module Bespoke
	class PostsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should get index if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			post1 = FactoryGirl.create(:post)
			post2 = FactoryGirl.create(:published_post)

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_includes assigns(:posts), post1
			assert_includes assigns(:posts), post2
		end

		test "should get index even if not logged in" do
			post1 = FactoryGirl.create(:post)
			post2 = FactoryGirl.create(:published_post)

			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
			assert_not_includes assigns(:posts), post1
			assert_includes assigns(:posts), post2
		end

		test "should get new if logged in" do
			user = FactoryGirl.create(:user)
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
			user = FactoryGirl.create(:user)
			sign_in user

			newPost = FactoryGirl.build(:post)

			assert_difference('Post.count') do
				post :create, post: {
					author_id: newPost.author_id,
					body: newPost.body,
					title: newPost.title
				}
			end

			assert_redirected_to post_path(assigns(:post))
			assert_match  /successfully created/, flash[:notice]
		end

		test "should not create post if not logged in" do
			newPost = FactoryGirl.build(:post)

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

		test "should show post if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			# Should show published post
			newPost = FactoryGirl.create(:published_post)

			get :show, id: newPost
			assert_response :success
			assert_equal assigns(:post), newPost

			# Should also show unpublished post
			newPost = FactoryGirl.create(:post)

			get :show, id: newPost
			assert_response :success
			assert_equal assigns(:post), newPost
		end

		test "should show post if not logged in" do
			# Should show published post
			newPost = FactoryGirl.create(:published_post)

			get :show, id: newPost
			assert_response :success
			assert_equal assigns(:post), newPost

			# Should not show unpublished post
			newPost = FactoryGirl.create(:post)

			# Controller should hide the "permission denied" in a "not-found"
			assert_raises ActiveRecord::RecordNotFound do
				get :show, id: newPost
			end
		end

		test "should get edit if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newPost = FactoryGirl.create(:post)

			get :edit, id: newPost
			assert_response :success
			assert_equal assigns(:post), newPost
		end

		test "should not get edit if not logged in" do
			newPost = FactoryGirl.create(:post)

			get :edit, id: newPost
			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should update post if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newPost = FactoryGirl.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			assert_redirected_to post_path(assigns(:post))
			assert_match /successfully updated/, flash[:notice]
		end

		test "should not update post if not logged in" do
			newPost = FactoryGirl.create(:post)

			patch :update, id: newPost, post: {
				author_id: newPost.author_id,
				body: newPost.body,
				title: newPost.title
			}

			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should destroy post if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newPost = FactoryGirl.create(:post)

			assert_difference('Post.count', -1) do
				delete :destroy, id: newPost
			end

			assert_redirected_to posts_path
			assert_match /successfully destroyed/, flash[:notice]
		end

		test "should not destroy post if not logged in" do
			newPost = FactoryGirl.create(:post)

			assert_no_difference('Post.count') do
				delete :destroy, id: newPost
			end

			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end
  end
end
