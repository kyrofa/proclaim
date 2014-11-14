class Bespoke::ApplicationController < ApplicationController

	private

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
end
