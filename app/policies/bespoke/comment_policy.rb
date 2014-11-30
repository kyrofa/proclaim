module Bespoke
	class CommentPolicy < ApplicationPolicy
		def create?
			true # Anyone can create a comment
		end

		class Scope < Scope
			def resolve
				scope.all
			end
		end
	end
end
