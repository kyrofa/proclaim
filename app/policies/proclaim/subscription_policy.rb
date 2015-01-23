module Proclaim
	class SubscriptionPolicy < ApplicationPolicy
		def index?
			not @user.nil? # A user can view the list of subscriptions
		end

		def show?
			true # Anyone can show the subscription since it requires a token
		end

		def create?
			# A user can subscribe to anything. Guests can only subscribe to
			# published posts or the blog in general.
			if @user.nil? and @record.post
				@record.post.published?
			else
				true
			end
		end

		def destroy?
			show?
		end

		class Scope < Scope
			def resolve
				if @user
					scope.all # Users can access all subscriptions
				else
					# Guests can see none
					scope.none
				end
			end
		end
	end
end
