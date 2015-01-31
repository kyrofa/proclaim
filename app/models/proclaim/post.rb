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

module Proclaim
	class Post < ActiveRecord::Base
		belongs_to :author, class_name: Proclaim.author_class
		has_many :comments, inverse_of: :post, dependent: :destroy
		has_many :subscriptions, inverse_of: :post, dependent: :destroy
		has_many :images, inverse_of: :post, dependent: :destroy
		accepts_nested_attributes_for :images, allow_destroy: true

		after_create { Proclaim.notify_new_post(self) }

		include AASM

		aasm column: :state, no_direct_assignment: true do
			state :draft, initial: true
			state :published

			event :publish do
				transitions from: :draft, to: :published

				before do
					self.published_at = DateTime.now
				end
			end
		end

		validates_presence_of :published_at, if: :published?
		validates :published_at, absence: true, unless: :published?

		validates_presence_of :title, :body, :author
		validate :verifyBodyHtml

		before_save :sanitizeBody
		after_save :notifyBlogSubscribersIfPublished

		attr_writer :excerpt_length
		def excerpt_length
			@excerpt_length || Proclaim.excerpt_length
		end

		def body_plaintext
			HTMLEntities.new.decode(Rails::Html::FullSanitizer.new.sanitize(body.gsub(/\r\n?/, ' ')))
		end

		def excerpt
			document = Nokogiri::HTML.fragment(body)

			unless document.text.empty?
				takeExcerptOf first_block_element_text(document)
			else
				""
			end
		end

		def notifyPostSubscribers(newComment)
			subscriptions.each do | subscription |
				subscription.deliver_new_comment_notification_email(newComment)
			end
		end

		private

		def verifyBodyHtml
			if not errors.messages.include?(:body) and
			   body_plaintext.strip.empty? and
			   Nokogiri::HTML.fragment(body).css("img").empty?
				errors.add :body, :empty
			end
		end

		def sanitizeBody
			unless Proclaim.editor_whitelist_tags.blank? and
			       Proclaim.editor_whitelist_attributes.blank?
				sanitizer = Rails::Html::WhiteListSanitizer.new
				self.body = sanitizer.sanitize(
				                   body,
				                   tags: Proclaim.editor_whitelist_tags,
				                   attributes: Proclaim.editor_whitelist_attributes)
			end
		end

		def takeExcerptOf(text)
			if excerpt_length >= text.length
				return text
			end

			excerpt = text.slice(0, excerpt_length)

			if text.slice(excerpt_length) =~ /\s/
				return excerpt.strip
			end

			# Make sure words aren't interrupted
			excerpt.slice(0, excerpt.rindex(/\s/, excerpt.length)).strip
		end

		def first_block_element_text(nokogiri_node)
			if nokogiri_node.text?
				return block_element_text(nokogiri_node.parent)
			end

			nokogiri_node.children.each do |child|
				result = first_block_element_text(child)
				if result
					return result
				end
			end

			nil
		end

		def block_element_text(nokogiri_block_element)
			text = String.new
			nokogiri_block_element.children.each do | child |
				if child.text? or (child.description.try(:inline?))
					text += child.text
				else
					break # Stop at the first non-inline non-text element
				end
			end

			return text
		end

		def notifyBlogSubscribersIfPublished
			# If we just published this post, notify the subscribers
			if published? and state_changed?
				Subscription.blog_subscriptions.each do | subscription |
					subscription.deliver_new_post_notification_email(self)
				end
			end
		end
	end
end
