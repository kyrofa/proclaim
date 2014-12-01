module Bespoke
	class CommentPolicy < ApplicationPolicy
		def create?
			true # Anyone can create a comment
		end

		def update?
			not @user.nil?
		end

		def destroy?
			not @user.nil?
		end

		class Scope < Scope
			def resolve
				scope.all
			end
		end
	end
end
