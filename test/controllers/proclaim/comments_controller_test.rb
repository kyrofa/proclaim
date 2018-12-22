require 'test_helper'

module Proclaim
	class CommentsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should create root comment if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			# Users should be able to make comments on unpublished posts
			newComment = FactoryBot.build(:comment)
			assert_create_comment newComment

			# Users should also be able to make comments on published posts
			newComment = FactoryBot.build(:published_comment)
			assert_create_comment newComment
		end

		test "should create reply if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			# Users should be able to make replies to comments on unpublished posts
			parent = FactoryBot.create(:comment)
			reply = FactoryBot.build(:comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, 1, 1, parent

			# Users should be able to make replies to comments on published posts
			parent = FactoryBot.create(:published_comment)
			reply = FactoryBot.build(:published_comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, 1, 1, parent
		end

		test "should create root comment if not logged in" do
			# Guests should not be able to make comments on unpublished comments
			newComment = FactoryBot.build(:comment)
			refute_create_comment newComment

			# Guests should be able to make comments on published comments
			newComment = FactoryBot.build(:published_comment)
			assert_create_comment newComment
		end

		test "should create reply if not logged in" do
			# Guests should not be able to make replies to comments on unpublished posts
			parent = FactoryBot.create(:comment)
			reply = FactoryBot.build(:comment,
			                          post: parent.post,
			                          parent: parent)
			refute_create_comment reply, 1, 1, parent

			# Guests should be able to make replies to comments on published posts
			parent = FactoryBot.create(:published_comment)
			reply = FactoryBot.build(:published_comment,
			                          post: parent.post,
			                          parent: parent)
			assert_create_comment reply, 1, 1, parent
		end

		test "should not create root comment if spammy" do
			newComment = FactoryBot.build(:published_comment)
			refute_create_comment newComment, 1, 2
		end

		test "should not create reply if spammy" do
			parent = FactoryBot.create(:published_comment)
			reply = FactoryBot.build(:published_comment,
			                          post: parent.post,
			                          parent: parent)
			refute_create_comment reply, 3, 4, parent
		end

		test "should update root comment if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newComment = FactoryBot.create(:comment)
			assert_update_comment newComment
		end

		test "should not update root comment if not logged in" do
			newComment = FactoryBot.create(:comment)
			refute_update_comment newComment
		end

		test "should destroy root comment if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			newComment = FactoryBot.create(:comment)

			assert_difference('Comment.count', -1) do
				delete :destroy, format: :json, id: newComment
			end
		end

		test "should not destroy root comment if not logged in" do
			newComment = FactoryBot.create(:comment)

			assert_no_difference('Comment.count') do
				delete :destroy, format: :json, id: newComment
			end

			assert_response :unauthorized
		end

		private

		def assert_create_comment(comment, antispam_solution = 1,
		                          antispam_answer = 1, parent = nil,
		                          subscription = nil)
			subscription_params = nil
			if subscription
				subscription_params = {
					subscribe: true,
					email: subscription.email
				}
			end

			antispam_params = nil
			if antispam_solution and antispam_answer
				antispam_params = {
					solution: antispam_solution,
					answer: antispam_answer
				}
			end

			assert_difference('Comment.count', 1,
			                  "A comment should have been created") do
				post :create, format: :json,
					comment: {
						author: comment.author,
						body: comment.body,
						post_id: comment.post_id,
						parent_id: comment.parent_id
					},
					subscription: subscription_params,
					antispam: antispam_params
			end

			if parent
				parent.reload # Refresh parent to pull in new associations
				assert_equal 1, parent.children.count,
				             "The parent should have a child!"

				newComment = parent.children.first
				assert_equal comment.author, newComment.author
				assert_equal comment.body, newComment.body
			end

			json = JSON.parse(@response.body)
			assert_not_nil json["id"], "The returned JSON should include the ID!"
			assert_not_nil json["html"],
			               "The returned JSON should include the HTML containing the comment!"
		end

		def refute_create_comment(comment, antispam_solution = 1,
		                          antispam_answer = 1, parent = nil,
		                          subscription = nil)
			subscription_params = nil
			if subscription
				subscription_params = {
					subscribe: true,
					email: subscription.email
				}
			end

			antispam_params = nil
			if antispam_solution and antispam_answer
				antispam_params = {
					solution: antispam_solution,
					answer: antispam_answer
				}
			end

			assert_no_difference('Comment.count',
			                     "A comment should not be created!") do
				post :create, format: :json,
					comment: {
						author: comment.author,
						body: comment.body,
						post_id: comment.post_id,
						parent_id: comment.parent_id
					},
					subscription: subscription_params,
					antispam: antispam_params
			end

			if antispam_solution == antispam_answer
				assert_response :not_found
			else
				assert_response :unprocessable_entity
			end
		end

		def assert_update_comment(comment)
			patch :update, format: :json, params: {
				id: comment,
				comment: {
					author: comment.author,
					body: comment.body,
					post_id: comment.post_id
				}
			}

			json = JSON.parse(@response.body)
			assert_not_nil json["id"]
			assert_not_nil json["html"]
		end

		def refute_update_comment(comment)
			patch :update, format: :json, params: {
				id: comment,
				comment: {
					author: comment.author,
					body: comment.body,
					post_id: comment.post_id
				}
			}

			assert_response :unauthorized
		end
	end
end
