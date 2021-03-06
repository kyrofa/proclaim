# == Schema Information
#
# Table name: proclaim_posts
#
#  id           :integer          not null, primary key
#  author_id    :integer
#  title        :string           default(""), not null
#  body         :text             default(""), not null
#  quill_body   :text             default(""), not null
#  state        :string           default("draft"), not null
#  slug         :string
#  published_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

module Proclaim
	class Post < ActiveRecord::Base
		belongs_to :author, class_name: Proclaim.author_class
		has_many :comments, inverse_of: :post, dependent: :destroy
		has_many :subscriptions, through: :comments

		extend FriendlyId
		friendly_id :slug_candidates, use: :history

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

		validates_presence_of :title, :subtitle, :body, :quill_body, :author
		validate :verifyBodyHtml

		after_validation :move_friendly_id_error_to_title

		# Using after_commit since we use deliver_later and re-load them from the database
		after_commit :notifyBlogSubscribersIfPublished, on: [:create, :update]

		# Track views
		acts_as_punchable

		attr_writer :excerpt_length
		def excerpt_length
			@excerpt_length ||= Proclaim.excerpt_length
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
				# Don't notify the commenter of own comment
				if subscription.comment_id != newComment.id
					subscription.deliver_new_comment_notification_email(newComment)
				end
			end
		end

		def feature_image
			document = Nokogiri::HTML.fragment(body)
			return nil if document.children.empty?

			first_element_images = document.children.first.css("img")
			return nil if first_element_images.empty?

			return first_element_images.first.attr "src"
		end

		private

		# Only save the slug history if the post is published
		def create_slug
			# No real reason to keep a slug history unless it's been published
			unless published?
				slugs.destroy_all
			end

			super
		end

		def body_plaintext
			HTMLEntities.new.decode(Rails::Html::FullSanitizer.new.sanitize(body.gsub(/\r\n?/, ' ')))
		end

		def should_generate_new_friendly_id?
			title_changed? || super
		end

		def move_friendly_id_error_to_title
			errors.add :title, *errors.delete(:friendly_id) if errors[:friendly_id].present?
		end

		# Try building a slug based on the following fields in
		# increasing order of specificity.
		def slug_candidates
			[
				:title,
				[:title, :id]
			]
		end

		def verifyBodyHtml
			if not errors.messages.include?(:body) and
			   body_plaintext.strip.empty? and
			   Nokogiri::HTML.fragment(body).css("img").empty?
				errors.add :body, :empty
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
				text = block_element_text(nokogiri_node.parent).strip

				return text unless text.empty?
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
			if published? and saved_change_to_state?
				Proclaim.notify_post_published(self)

				Subscription.blog_subscriptions.each do | subscription |
					subscription.deliver_new_post_notification_email(self)
				end
			end
		end
	end
end
