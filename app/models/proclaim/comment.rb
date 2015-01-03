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
		after_initialize :maintainPost
		after_create :notifyPostSubscribers

		validates_presence_of :body, :author, :post

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
