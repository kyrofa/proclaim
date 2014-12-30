module Bespoke
	class PostPolicy < ApplicationPolicy
		def index?
			true # Anyone can list posts
		end

		def show?
			if @user
				true # A logged in user can see anything
			else
				@record.published? # Guests can see published posts
			end
		end

		def create?
			not @user.nil? # As long as there's a user, it can create posts
		end

		def update?
			not @user.nil? # As long as there's a user, it can update posts
		end

		def destroy?
			not @user.nil? # As long as there's a user, it can destroy posts
		end

		class Scope < Scope
			def resolve
				if @user
					scope.all # Users can access all posts
				else
					# Guests can see all posts that are published
					scope.published
				end
			end
		end
	end
end
