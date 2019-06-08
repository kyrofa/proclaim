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

module Proclaim
	class Comment < ActiveRecord::Base
		acts_as_tree order: 'created_at ASC', dependent: :destroy
		belongs_to :post, inverse_of: :comments
		has_one :subscription, inverse_of: :comment, dependent: :destroy
		after_initialize :maintainPost

		# Using after_commit since we use deliver_later and re-load them from the database
		after_create_commit :notifyPostSubscribers
		after_create { Proclaim.notify_new_comment(self) }

		validates_presence_of :body, :author, :post

		accepts_nested_attributes_for :subscription, reject_if: :all_blank

		private

		def maintainPost
			if parent
				self.post = parent.post
			end
		end

		def notifyPostSubscribers
			post.notifyPostSubscribers(self)
		end
	end
end
