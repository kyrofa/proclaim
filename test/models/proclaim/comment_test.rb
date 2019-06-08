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
		include ActionMailer::TestHelper

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

		test "should deliver new comment email upon creation" do
			post = FactoryBot.create(:published_post)
			comment = FactoryBot.create(:comment, post: post)
			subscription = FactoryBot.create(:subscription, comment: comment)

			post.reload # Refresh post to pull in new associations

			assert_enqueued_email_with SubscriptionMailer, :new_comment_notification_email, args: {subscription_id: subscription.id, comment_id: Comment.maximum(:id).next} do
				FactoryBot.create(:comment, post: post)
			end
		end

		test "should not deliver new comment email upon edit" do
			comment = FactoryBot.create(:published_comment)
			subscription = FactoryBot.create(:subscription, comment: comment)
			comment = FactoryBot.create(:comment, post: comment.post)

			comment.author = "Edit Author"
			comment.body = "Edit Body"

			assert_no_enqueued_emails do
				comment.save
			end
		end
	end
end
