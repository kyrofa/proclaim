module Proclaim
	class SubscriptionPolicy < ApplicationPolicy
		def create?
			# A user can subscribe to anything. Guests can only subscribe to
			# published posts or the blog in general.
			if @user.nil? and @record.post
				@record.post.published?
			else
				true
			end
		end

		def unsubscribe?
			destroy?
		end

		def destroy?
			true # Anyone can unsubscribe (it requires a token anyway)
		end

		class Scope < Scope
			def resolve
				if @user
					scope.all # Users can access all subscriptions
				else
					# Guests can see none
					nil
				end
			end
		end
	end
end
