module Bespoke
	class CommentPolicy < ApplicationPolicy
		def create?
			# Users can comment on whatever they want, but guests can only comment
			# on published posts
			if @user
				true
			else
				@record.post.published?
			end
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
