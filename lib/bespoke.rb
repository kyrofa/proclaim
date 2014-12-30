require "bespoke/engine"

module Bespoke
	mattr_accessor :author_class
	@@author_class = "User"

	mattr_accessor :current_author_method
	@@current_author_method = :current_user

	mattr_accessor :author_name_method
	@@author_name_method = :name

	mattr_accessor :authentication_method
	@@authentication_method = :authenticate_user

	mattr_accessor :asset_host
	@@asset_host = nil

	mattr_accessor :excerpt_length
	@@excerpt_length = 500 # 500 characters (won't interrupt words)

	def self.setup
		yield self
	end
end
