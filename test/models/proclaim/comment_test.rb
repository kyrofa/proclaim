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
	class CommentTest < ActiveSupport::TestCase
		test "ensure factory is good" do
			comment = FactoryBot.build(:comment)

			assert comment.save, "Factory needs to be updated to save successfully"
		end

		test "ensure body is required" do
			comment = FactoryBot.build(:comment, body: "")

			refute comment.save, "Comment should require a body!"
		end

		test "ensure post is required" do
			comment = FactoryBot.build(:comment, post_id: nil)

			refute comment.save, "Comment should require a post_id!"

			# Post with 12345 shouldn't exist
			comment = FactoryBot.build(:comment, post_id: 12345)

			refute comment.save, "Comment should require a valid post!"
		end
	end
end
