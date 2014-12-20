# == Schema Information
#
# Table name: bespoke_posts
#
#  id               :integer          not null, primary key
#  author_id        :integer
#  title            :string(255)      default(""), not null
#  body             :text             default(""), not null
#  published        :boolean          default(FALSE), not null
#  publication_date :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

module Bespoke
	class Post < ActiveRecord::Base
		belongs_to :author, class_name: Bespoke.author_class
		has_many :comments, inverse_of: :post, dependent: :destroy
		has_many :subscriptions, inverse_of: :post, dependent: :destroy

		validates_presence_of :title, :body, :author
		validates_presence_of :publication_date, if: :published

		after_save :notifyBlogSubscribersIfPublished

		def excerpt
			excerptLength = Bespoke.excerpt_length

			if excerptLength >= body.length
				return body
			end

			excerpt = body.slice(0, excerptLength)

			if body.slice(excerptLength) =~ /\s/
				return excerpt.strip
			end

			# Make sure words aren't interrupted
			excerpt.slice(0, excerpt.rindex(/\s/, excerpt.length)).strip
		end

		def notifyPostSubscribers(newComment)
			Rails::logger.debug "::::::::::::: ADDED NEW COMMENT! ::::::::::"
			subscriptions.each do | subscription |
				subscription.deliver_new_comment_notification_email(newComment)
			end
		end

		private

		def notifyBlogSubscribersIfPublished
			# If we just published this post, notify the subscribers
			if publication_date and publication_date_was.nil?
				Subscription.blog_subscriptions.each do | subscription |
					subscription.deliver_new_post_notification_email(self)
				end
			end
		end
	end
end
