require "bespoke/engine"

module Bespoke
	mattr_accessor :author_class

	def self.setup
		yield self
	end
end
