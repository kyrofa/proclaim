require "bespoke/engine"

module Bespoke
	mattr_accessor :author_table_name
	@@author_table_name = :users

	def self.setup
		yield self
	end
end
