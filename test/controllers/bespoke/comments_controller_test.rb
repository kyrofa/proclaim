require 'test_helper'

module Bespoke
	class CommentsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should create comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newComment = FactoryGirl.build(:comment)

			assert_difference('Comment.count') do
				post :create, format: :json, comment: {
					author: newComment.author,
					body: newComment.body,
					title: newComment.title,
					post_id: newComment.post_id
				}
			end

			json = JSON.parse(@response.body)
			assert_not_nil json["id"]
			assert_not_nil json["html"]
		end

		test "should create comment if not logged in" do
			newComment = FactoryGirl.build(:comment)

			assert_difference('Comment.count') do
				post :create, format: :json, comment: {
					author: newComment.author,
					body: newComment.body,
					title: newComment.title,
					post_id: newComment.post_id
				}
			end

			json = JSON.parse(@response.body)
			assert_not_nil json["id"]
			assert_not_nil json["html"]
		end

		test "should update comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newComment = FactoryGirl.create(:comment)

			patch :update, format: :json, id: newComment, comment: {
				author: newComment.author,
				body: newComment.body,
				title: newComment.title,
				post_id: newComment.post_id
			}

			json = JSON.parse(@response.body)
			assert_not_nil json["id"]
			assert_not_nil json["html"]
		end

		test "should not update comment if not logged in" do
			newComment = FactoryGirl.create(:comment)

			patch :update, format: :json, id: newComment, comment: {
				author: newComment.author,
				body: newComment.body,
				title: newComment.title,
				post_id: newComment.post_id
			}

			assert_response :unauthorized
		end

		test "should destroy comment if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newComment = FactoryGirl.create(:comment)

			assert_difference('Comment.count', -1) do
				delete :destroy, format: :json, id: newComment
			end
		end

		test "should not destroy comment if not logged in" do
			newComment = FactoryGirl.create(:comment)

			assert_no_difference('Comment.count') do
				delete :destroy, format: :json, id: newComment
			end

			assert_response :unauthorized
		end
	end
end
