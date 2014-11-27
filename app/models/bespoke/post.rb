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

		validates_presence_of :title, :body, :author
		validates_presence_of :publication_date, if: :published
	end
end
