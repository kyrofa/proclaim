require 'test_helper'

module Proclaim
	class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
		include Engine.routes.url_helpers

		setup do
			# By default, no one is logged in
			sign_in nil
		end

		test "should get index if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			subscription1 = FactoryBot.create(:subscription)
			subscription2 = FactoryBot.create(:subscription)

			get subscriptions_url
			assert_response :success
			assert_match subscription1.email, @response.body
			assert_match subscription2.email, @response.body
		end

		test "should not get index if not logged in" do
			get subscriptions_url
			assert_response :redirect
			assert_match(/not authorized/, flash[:error])
		end

		test "should get show if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			subscription = FactoryBot.create(:subscription)

			get subscription_url subscription.token
			assert_response :success
			assert_match subscription.name, @response.body
		end

		test "should get show if not logged in" do
			subscription = FactoryBot.create(:subscription)

			get subscription_url subscription.token
			assert_response :success
			assert_match subscription.name, @response.body
		end

		test "show should return not found is token is invalid" do
			assert_raises ActiveRecord::RecordNotFound do
				get subscription_url 12345
			end
		end

		test "should get new if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			get new_subscription_url
			assert_response :success
		end

		test "should get new if not logged in" do
			get new_subscription_url
			assert_response :success
		end

		test "should create subscription if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			assert_create_subscription(FactoryBot.build(:subscription))
		end

		test "should create subscription if not logged in" do
			assert_create_subscription(FactoryBot.build(:subscription))
		end

		test "should not create subscription if spammy" do
			assert_no_difference('Subscription.count') do
				post_subscription(FactoryBot.build(:subscription), 5, 3)
			end
		end

		test "should delete subscription if logged in" do
			user = FactoryBot.create(:user)
			sign_in user

			subscription = FactoryBot.create(:subscription)

			assert_difference('Subscription.count', -1) do
				delete subscription_url(subscription.token)
			end

			# If a user is logged in, deletion should take them back to the
			# subscriptions index
			assert_redirected_to subscriptions_path
		end

		test "should delete subscription if not logged in" do
			subscription = FactoryBot.create(:subscription)

			assert_difference('Subscription.count', -1) do
				delete subscription_url(subscription.token)
			end

			# If no user is logged in, deletion should take them back to the
			# posts index
			assert_redirected_to posts_path
		end

		private

		def assert_create_subscription(subscription)
			assert_difference('Subscription.count') do
				post_subscription(subscription, 5, 5)
			end

			assert_redirected_to subscription_path(Subscription.last.token)
		end

		def post_subscription(subscription, antispam_solution, antispam_answer)
			post subscriptions_url, params: {
				subscription: {
					name: subscription.name,
					email: subscription.email,
				},
				antispam: {
					solution: antispam_solution,
					answer: antispam_answer,
				}
			}
		end
	end
end
