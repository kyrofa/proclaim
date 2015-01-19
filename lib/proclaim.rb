require "proclaim/engine"

module Proclaim
	mattr_accessor :author_class
	@@author_class = "User"

	mattr_accessor :author_name_method
	@@author_name_method = :name

	mattr_accessor :current_author_method
	@@current_author_method = "current_#{@@author_class.underscore}".to_sym

	mattr_accessor :authentication_method
	@@authentication_method = "authenticate_#{@@author_class.underscore}!".to_sym

	mattr_accessor :excerpt_length
	@@excerpt_length = 500 # 500 characters (won't interrupt words)

	mattr_accessor :editor_toolbar_buttons
	@@editor_toolbar_buttons = ['bold', 'italic', 'underline', 'anchor',
	                            'header1', 'header2', 'quote']

	mattr_accessor :editor_whitelist_tags
	@@editor_whitelist_tags = %w(h1 h2 h3 h4 h5 h6
	                             div p blockquote
	                             ul ol li
	                             a b strong i u
	                             img figure
	                             pre sup sub br)

	mattr_accessor :editor_whitelist_attributes
	@@editor_whitelist_attributes = %w(class id style href title src alt align
	                                   draggable)

	mattr_accessor :mailer_sender
	@@mailer_sender = nil

	def self.setup
		yield self
	end
end
