require 'test_helper'

module Bespoke
	class SubscriptionsControllerTest < ActionController::TestCase
		setup do
			@routes = Engine.routes

			@controller.stubs(:current_user).returns(nil)
			@controller.stubs(:authenticate_user).returns(false)
		end

		test "should create subscription if logged in" do
			user = FactoryGirl.create(:user)
			sign_in user

			newSubscription = FactoryGirl.build(:subscription)

			assert_difference('Subscription.count') do
				post :create, subscription: {
					email: newSubscription.email
				}
			end

			assert_redirected_to :subscribed
		end

		test "should create subscription if not logged in" do
			newSubscription = FactoryGirl.build(:subscription)

			assert_difference('Subscription.count') do
				post :create, subscription: {
					email: newSubscription.email
				}
			end

			assert_redirected_to :subscribed
		end

		test "ensure token resolves to correct subscription" do
			subscription1 = FactoryGirl.create(:subscription)
			subscription2 = FactoryGirl.create(:subscription)

			get :unsubscribe, token: subscription1.token
			assert_response :success
			assert_equal subscription1, assigns(:subscription)

			get :unsubscribe, token: subscription2.token
			assert_response :success
			assert_equal subscription2, assigns(:subscription)
		end

		test "ensure deletion with token actually deletes correct subscription" do
			subscription1 = FactoryGirl.create(:subscription)
			subscription2 = FactoryGirl.create(:subscription)

			assert_difference('Subscription.count', -1) do
				delete :destroy, token: subscription1.token
			end
			assert_equal subscription2, Subscription.first
			assert_redirected_to :unsubscribed

			assert_difference('Subscription.count', -1) do
				delete :destroy, token: subscription2.token
			end
			assert_redirected_to :unsubscribed
		end
	end
end
