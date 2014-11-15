# == Schema Information
#
# Table name: bespoke_comments
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  parent_id  :integer
#  author     :string(255)
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

module Bespoke
	class Comment < ActiveRecord::Base
		acts_as_tree order: 'created_at DESC', dependent: :destroy
		belongs_to :post, inverse_of: :comments, dependent: :destroy
		before_save :maintainPost

		validates_presence_of :title, :body, :author

		private

		def maintainPost
			if parent
				self.post = parent.post
			end
		end
	end
end
