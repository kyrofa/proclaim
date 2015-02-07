require 'test_helper'

module Proclaim
	class SubscriptionsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should get index if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			subscription1 = FactoryGirl.create(:subscription)
			subscription2 = FactoryGirl.create(:subscription)

			get :index
			assert_response :success
			assert_not_nil assigns(:subscriptions)
			assert_includes assigns(:subscriptions), subscription1
			assert_includes assigns(:subscriptions), subscription2
		end

		test "should not get index if not logged in" do
			get :index
			assert_response :redirect
			assert_match /not authorized/, flash[:error]
		end

		test "should get show if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			subscription = FactoryGirl.create(:subscription)

			get :show, token: subscription.token
			assert_response :success
			assert_equal subscription, assigns(:subscription)
		end

		test "should get show if not logged in" do
			subscription = FactoryGirl.create(:subscription)

			get :show, token: subscription.token
			assert_response :success
			assert_equal subscription, assigns(:subscription)
		end

		test "should get new if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			get :new
			assert_response :success
			assert_not_nil assigns(:subscription)
		end

		test "should get new if not logged in" do
			get :new
			assert_response :success
			assert_not_nil assigns(:subscription)
		end

		test "should create subscription if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newSubscription = FactoryGirl.build(:subscription)

			assert_difference('Subscription.count') do
				post :create,
					subscription: {
						name: newSubscription.name,
						email: newSubscription.email
					},
					antispam: {
						solution: 5,
						answer: 5
					}
			end

			assert_redirected_to subscription_path(assigns(:subscription).token)
		end

		test "should create subscription if not logged in" do
			newSubscription = FactoryGirl.build(:subscription)

			assert_difference('Subscription.count') do
				post :create,
					subscription: {
						name: newSubscription.name,
						email: newSubscription.email
					},
					antispam: {
						solution: 3,
						answer: 3
					}
			end

			assert_redirected_to subscription_path(assigns(:subscription).token)
		end

		test "should not create subscription if spammy" do
			newSubscription = FactoryGirl.build(:subscription)

			assert_no_difference('Subscription.count') do
				post :create,
					subscription: {
						name: newSubscription.name,
						email: newSubscription.email
					},
					antispam: {
						solution: 5,
						answer: 3
					}
			end
		end

		test "should delete subscription if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			subscription = FactoryGirl.create(:subscription)

			assert_difference('Subscription.count', -1) do
				delete :destroy, token: subscription.token
			end

			# If a user is logged in, deletion should take them back to the
			# subscriptions index
			assert_redirected_to subscriptions_path
		end

		test "should delete subscription if not logged in" do
			subscription = FactoryGirl.create(:subscription)

			assert_difference('Subscription.count', -1) do
				delete :destroy, token: subscription.token
			end

			# If no user is logged in, deletion should take them back to the
			# posts index
			assert_redirected_to posts_path
		end
	end
end
