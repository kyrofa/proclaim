# == Schema Information
#
# Table name: bespoke_posts
#
#  id         :integer          not null, primary key
#  author_id  :integer
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

module Bespoke
	class Post < ActiveRecord::Base
		belongs_to :author, class_name: "User", inverse_of: :posts

		validates_presence_of :title, :body, :author
	end
end
