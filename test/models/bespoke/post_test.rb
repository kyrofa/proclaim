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

require 'test_helper'

module Bespoke
	class PostTest < ActiveSupport::TestCase
#		test "ensure factory is good" do
#			post = FactoryGirl.build(:post)

#			assert post.save, "Factory needs to be updated to save successfully"
#		end

#		test "ensure title is required" do
#			post = FactoryGirl.build(:post, title: "")

#			refute post.save, "Post should require a title!"
#		end

#		test "ensure body is required" do
#			post = FactoryGirl.build(:post, body: "")

#			refute post.save, "Post should require a body!"
#		end

#		test "ensure author is required" do
#			post = FactoryGirl.build(:post, author_id: nil)

#			refute post.save, "Post should require an author_id!"

#			# Author with 12345 shouldn't exist
#			post = FactoryGirl.build(:post, author_id: 12345)

#			refute post.save, "Post should require a valid author!"
#		end

#		test "verify publication date requirement" do
#			post = FactoryGirl.build(:post, published: false)

#			assert post.save, "Post should save without a publication date if not published!"

#			post = FactoryGirl.build(:post, published: true)

#			refute post.save, "Post should not save if published without a publication date!"

#			post = FactoryGirl.build(:post, published: true, publication_date: Date.today)

#			assert post.save, "Post should save successfully if published with a publication date!"
#		end
	end
end
