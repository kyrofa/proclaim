class Bespoke::ApplicationController < ApplicationController
	include Pundit

	rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

	private

	def user_not_authorized
		flash[:error] = "You are not authorized to perform this action."
		redirect_to(request.referrer || root_path)
	end

	def authenticate_author
		begin
			send(Bespoke.authentication_method)
		rescue NoMethodError
			raise "Bespoke doesn't know how to authenticate users! Please" \
			      " ensure that `Bespoke.authentication_path` is valid."
		end
	end

	def current_author
		begin
			send(Bespoke.current_author_method)
		rescue NoMethodError
			raise "Bespoke doesn't know how to get the current author! Please" \
			      " ensure that `Bespoke.current_author_method` is valid."
		end
	end

	def pundit_user
		current_author
	end
end
