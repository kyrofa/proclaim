require 'test_helper'

module Bespoke
	class PostsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes
			@post = FactoryGirl.create(:post)
		end

		test "should get index even if not logged in" do
			get :index
			assert_response :success
			assert_not_nil assigns(:posts)
		end

		test "should get new" do
			get :new, use_route: :bespoke
			assert_response :success
		end

#    test "should create post" do
#      assert_difference('Post.count') do
#        post :create, use_route: :bespoke, post: { author_id: @post.author_id, body: @post.body, title: @post.title }
#      end

#      assert_redirected_to post_path(assigns(:post))
#    end

#    test "should show post" do
#      get :show, use_route: :bespoke, id: @post
#      assert_response :success
#    end

#    test "should get edit" do
#      get :edit, use_route: :bespoke, id: @post
#      assert_response :success
#    end

#    test "should update post" do
#      patch :update, use_route: :bespoke, id: @post, post: { author_id: @post.author_id, body: @post.body, title: @post.title }
#      assert_redirected_to post_path(assigns(:post))
#    end

#    test "should destroy post" do
#      assert_difference('Post.count', -1) do
#        delete :destroy, use_route: :bespoke, id: @post
#      end

#      assert_redirected_to posts_path
#    end
  end
end
