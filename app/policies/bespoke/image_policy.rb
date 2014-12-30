module Bespoke
	class ImagePolicy < ApplicationPolicy
		def cache?
			create?
		end

		def create?
			not @user.nil? # As long as there's a user, it can create images
		end

		def discard?
			destroy?
		end

		def destroy?
			not @user.nil? # As long as there's a user, it can destroy images
		end

		class Scope < Scope
			def resolve
				if @user
					scope.all # Users can access all images
				else
					nil
				end
			end
		end
	end
end
