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
	class PostPublishedCallbackTest < ActiveSupport::TestCase
		setup do
			@callback_called = false

			Proclaim.after_post_published do
				@callback_called = true
			end
		end

		teardown do
			Proclaim.reset_post_published_callbacks
		end

		test "ensure callback supports blocks and procs" do
			assert_nothing_raised do
				Proclaim.after_post_published lambda {|post| puts "test Proc"}
			end

			assert_nothing_raised do
				Proclaim.after_post_published do
					puts "test block"
				end
			end

			assert_raise RuntimeError do
				Proclaim.after_post_published :foo
			end
		end

		test "ensure callback is called when published" do
			post = FactoryBot.build(:post)
			refute @callback_called

			post.publish
			refute @callback_called # Not saved yet, so callbacks shouldn't happen

			post.save
			assert @callback_called
		end

		test "ensure post cannot be published twice" do
			post = FactoryBot.build(:published_post)
			assert_raise AASM::InvalidTransition do
				post.publish
			end
		end

		test "ensure callback is not called when created" do
			post = FactoryBot.build(:post)
			refute @callback_called

			post.save
			refute @callback_called,
			       "Callback shouldn't be called unless the post is published!"
		end

		test "ensure callback is not called when updated" do
			post = FactoryBot.create(:post)
			@callback_called = false

			post.save
			refute @callback_called
		end
	end
end
