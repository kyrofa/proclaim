# == Schema Information
#
# Table name: proclaim_posts
#
#  id               :integer          not null, primary key
#  author_id        :integer
#  title            :string           default(""), not null
#  body             :text             default(""), not null
#  published        :boolean          default("f"), not null
#  publication_date :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

module Proclaim
	class PostTest < ActiveSupport::TestCase
		test "ensure factory is good" do
			post = FactoryGirl.build(:post)

			assert post.save, "Factory needs to be updated to save successfully"
		end

		test "ensure title is required" do
			post = FactoryGirl.build(:post, title: "")

			refute post.save, "Post should require a title!"
		end

		test "ensure body is required" do
			post = FactoryGirl.build(:post, body: nil)
			refute post.save, "Post should require a body!"

			post = FactoryGirl.build(:post, body: "")
			refute post.save, "Post should require a body!"

			post = FactoryGirl.build(:post, body: "<p></p>")
			refute post.save, "Post should require a body to have text!"

			post = FactoryGirl.build(:post, body: "\r\n \n \r")
			refute post.save, "Post should require a body to have text!"

			post = FactoryGirl.build(:post, body: "<p></p>\r\n<p></p>\n<p></p>\r")
			refute post.save, "Post should require a body to have text!"
		end

		test "ensure author is required" do
			post = FactoryGirl.build(:post, author_id: nil)

			refute post.save, "Post should require an author_id!"

			# Author with 12345 shouldn't exist
			post = FactoryGirl.build(:post, author_id: 12345)

			refute post.save, "Post should require a valid author!"
		end

		test "verify publication date requirement" do
			post = FactoryGirl.build(:post, published_at: nil)
			assert post.save, "Post should save without a publication date if not published!"

			post = FactoryGirl.build(:post, published_at: DateTime.now)
			refute post.save, "Post should not save with a publication date if not published!"

			post = FactoryGirl.build(:published_post)
			post.published_at = nil
			refute post.save, "Post should not save if published without a publication date!"

			post = FactoryGirl.build(:published_post)
			assert post.save, "Post should save successfully if published with a publication date!"
		end

		test "ensure publication date when published" do
			post = FactoryGirl.build(:post)
			assert_nil post.published_at

			post.publish
			assert_not_nil post.published_at

			assert post.save
		end

		test "verify publication can't be taken back" do
			post = FactoryGirl.build(:published_post)
			assert post.save

			assert_raises AASM::NoDirectAssignmentError do
				post.state = "draft"
			end
		end

		test "verify excerpt" do
			post = FactoryGirl.build(:post, body: "<div><p></p><p></p></div>")

			assert_equal "", post.excerpt

			post = FactoryGirl.build(:post, body: "<p>foo bar baz qux</p><p>y</p>")

			assert_equal "foo bar baz qux", post.excerpt

			post.excerpt_length = 10
			assert_equal "foo bar", post.excerpt

			post.excerpt_length = 11
			assert_equal "foo bar baz", post.excerpt

			post.excerpt_length = 12
			assert_equal "foo bar baz", post.excerpt

			post.excerpt_length = 15
			assert_equal "foo bar baz qux", post.excerpt

			post = FactoryGirl.build(:post,
			                         body: "<p>This is <strong>emphasized</strong>. This is a <a href=\"http://example.com\">link</a>.</p><p>foo</p>")
			assert_equal "This is emphasized. This is a link.", post.excerpt

			post = FactoryGirl.build(:post,
			                         body: "<p></p><div></div><p>foo</p>")
			assert_equal "foo", post.excerpt

			post = FactoryGirl.build(:post,
			                         body: "This is outside.<p>This is inside.</p>")
			assert_equal "This is outside.", post.excerpt
		end

		test "verify body sanitization" do
			post = FactoryGirl.create(:post,
			                          body: "foo <script>alert('bar');</script>")

			assert_equal "foo alert('bar');", post.body
		end

		test "verify slug presence" do
			post = FactoryGirl.build(:post, title: "New Post")
			assert_nil post.slug

			post.save
			assert_equal "new-post", post.slug

			assert_equal post, Post.friendly.find(post.slug)
			assert_equal post, Post.friendly.find(post.id),
			             "Should also be able to use regular-old ID"
		end

		test "verify slug uniqueness" do
			post = FactoryGirl.create(:post, title: "New Post")
			assert_equal "new-post", post.slug

			post = FactoryGirl.build(:post, title: "New Post") # Same title
			post.valid?

			assert post.save, "Title should not be required to be unique"
			assert_not_equal "new-post", post.slug, "Slugs should be unique"
		end

		test "verify unpublished post slug changes but does not keep history" do
			post = FactoryGirl.create(:post, title: "New Post")
			assert_equal "new-post", post.slug
			assert_equal post, Post.friendly.find(post.slug)

			post.title = "New Post Modified"
			post.save
			assert_equal "new-post-modified", post.slug,
			             "The slug should change if the post title changes"
			assert_equal post, Post.friendly.find(post.slug)

			# Assert that we cannot use the old slug
			refute Post.friendly.exists_by_friendly_id?("new-post"),
				    "Should not be able to use old slug on an unpublished post"
		end

		test "verify published post slug changes and keeps history" do
			post = FactoryGirl.create(:published_post, title: "New Post")
			assert_equal "new-post", post.slug
			assert_equal post, Post.friendly.find(post.slug)

			post.title = "New Post Modified"
			post.save
			assert_equal "new-post-modified", post.slug,
			             "The slug should change if the post title changes"
			assert_equal post, Post.friendly.find(post.slug)

			# Also assert that we can use the old slug (i.e. published links
			# can't be broken)
			assert_equal post, Post.friendly.find("new-post")
		end
	end
end
