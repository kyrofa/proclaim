require 'test_helper'

module Bespoke
	class CommentsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should create root comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			# Users should be able to make comments on unpublished posts
			newComment = FactoryGirl.build(:comment)
			assert_create_comment newComment

			# Users should also be able to make comments on published posts
			newComment = FactoryGirl.build(:published_comment)
			assert_create_comment newComment
		end

		test "should create reply if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			# Users should be able to make replies to comments on unpublished posts
			parent = FactoryGirl.create(:comment)
			reply = FactoryGirl.build(:comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, parent

			# Users should be able to make replies to comments on published posts
			parent = FactoryGirl.create(:published_comment)
			reply = FactoryGirl.build(:published_comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, parent
		end

		test "should create root comment if not logged in" do
			# Guests should not be able to make comments on unpublished comments
			newComment = FactoryGirl.build(:comment)
			refute_create_comment newComment

			# Guests should be able to make comments on published comments
			newComment = FactoryGirl.build(:published_comment)
			assert_create_comment newComment
		end

		test "should create reply if not logged in" do
			# Guests should not be able to make replies to comments on unpublished posts
			parent = FactoryGirl.create(:comment)
			reply = FactoryGirl.build(:comment,
			                          post: parent.post,
			                          parent: parent)
			refute_create_comment reply, parent

			# Guests should be able to make replies to comments on published posts
			parent = FactoryGirl.create(:published_comment)
			reply = FactoryGirl.build(:published_comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, parent
		end

		test "should update root comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newComment = FactoryGirl.create(:comment)
			assert_update_comment newComment
		end

		test "should not root update comment if not logged in" do
			newComment = FactoryGirl.create(:comment)
			refute_update_comment newComment
		end

		test "should destroy root comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newComment = FactoryGirl.create(:comment)

			assert_difference('Comment.count', -1) do
				delete :destroy, format: :json, id: newComment
			end
		end

		test "should not destroy root comment if not logged in" do
			newComment = FactoryGirl.create(:comment)

			assert_no_difference('Comment.count') do
				delete :destroy, format: :json, id: newComment
			end

			assert_response :unauthorized
		end

		private

		def assert_create_comment(comment, parent = nil)
			assert_difference('Comment.count', 1,
			                  "A comment should have been created") do
				post :create, format: :json, comment: {
					author: comment.author,
					body: comment.body,
					title: comment.title,
					post_id: comment.post_id,
					parent_id: comment.parent_id
				}
			end

			if parent
				parent.reload # Refresh parent to pull in new associations
				assert_equal 1, parent.children.count,
				             "The parent should have a child!"

				newComment = parent.children.first
				assert_equal comment.author, newComment.author
				assert_equal comment.title, newComment.title
				assert_equal comment.body, newComment.body
			end

			json = JSON.parse(@response.body)
			assert_not_nil json["id"], "The returned JSON should include the ID!"
			assert_not_nil json["html"],
			               "The returned JSON should include the HTML containing the comment!"
		end

		def refute_create_comment(comment, parent = nil)
			assert_no_difference('Comment.count',
			                     "A comment should not be created!") do
				post :create, format: :json, comment: {
					author: comment.author,
					body: comment.body,
					title: comment.title,
					post_id: comment.post_id
				}
			end

			assert_response :not_found
		end

		def assert_update_comment(comment)
			patch :update, format: :json, id: comment, comment: {
				author: comment.author,
				body: comment.body,
				title: comment.title,
				post_id: comment.post_id
			}

			json = JSON.parse(@response.body)
			assert_not_nil json["id"]
			assert_not_nil json["html"]
		end

		def refute_update_comment(comment)
			patch :update, format: :json, id: comment, comment: {
				author: comment.author,
				body: comment.body,
				title: comment.title,
				post_id: comment.post_id
			}

			assert_response :unauthorized
		end
	end
end
