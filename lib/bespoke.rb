require "bespoke/engine"

module Bespoke
	mattr_accessor :author_class
	@@author_class = "User"

	mattr_accessor :current_author_method
	@@current_author_method = :current_user

	mattr_accessor :authentication_method
	@@authentication_method = :authenticate_user

	def self.setup
		yield self
	end
end
