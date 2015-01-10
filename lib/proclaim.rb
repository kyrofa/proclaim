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
	@@editor_toolbar_buttons = ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote']

	def self.setup
		yield self
	end
end
