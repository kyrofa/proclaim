# == Schema Information
#
# Table name: proclaim_comments
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  parent_id  :integer
#  author     :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

module Proclaim
	class NewSubscriptionCallbackTest < ActiveSupport::TestCase
		setup do
			@callback_called = false

			Proclaim.after_new_subscription do
				@callback_called = true
			end
		end

		teardown do
			Proclaim.reset_new_subscription_callbacks
		end

		test "ensure callback supports blocks and procs" do
			assert_nothing_raised do
				Proclaim.after_new_subscription lambda {|subscription| puts "test Proc"}
			end

			assert_nothing_raised do
				Proclaim.after_new_subscription do
					puts "test block"
				end
			end

			assert_raise RuntimeError do
				Proclaim.after_new_subscription :foo
			end
		end

		test "ensure callback is called when created" do
			subscription = FactoryBot.build(:subscription)
			refute @callback_called

			subscription.save
			assert @callback_called
		end

		test "ensure callback is not called when updated" do
			subscription = FactoryBot.create(:subscription)
			@callback_called = false

			subscription.save
			refute @callback_called
		end
	end
end
