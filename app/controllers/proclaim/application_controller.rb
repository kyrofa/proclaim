module Proclaim
	class ApplicationController < ::ApplicationController
		protect_from_forgery with: :exception

		include Pundit

		rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

		private

		def user_not_authorized
			flash[:error] = "You are not authorized to perform this action."
			redirect_to(request.referrer || root_path)
		end

		def authenticate_author
			begin
				send(Proclaim.authentication_method)
			rescue NoMethodError
				raise "Proclaim doesn't know how to authenticate users! Please" \
					" ensure that `Proclaim.authentication_path` is valid."
			end
		end

		def current_author
			begin
				send(Proclaim.current_author_method)
			rescue NoMethodError
				raise "Proclaim doesn't know how to get the current author! Please" \
					" ensure that `Proclaim.current_author_method` is valid."
			end
		end

		def pundit_user
			current_author
		end

		def image_id_and_name_from_url(url)
			match = url.match(/([^\/]*?)\/([^\/]*)\z/)

			return match[1], match[2]
		end

		def cache_name_from_url(url)
			url.match(/[^\/]*?\/[^\/]*\z/)
		end

		def handleJsonRequest(object, options = {})
			operation = options[:operation] || true
			successJson = options[:success_json] || true
			failureJson = options[:failure_json] || lambda {object.errors.full_messages}
			unauthorizedStatus = options[:unauthorized_status] || :unauthorized

			begin
				authorize object

				yield if block_given?
				return if performed? # Don't continue if the block rendered

				respond_to do |format|
					if (operation == true) or (operation.respond_to?(:call) and operation.call)
						if successJson.respond_to? :call
							successJson = successJson.call
						end

						format.json { render json: successJson }
					else
						if failureJson.respond_to? :call
							failureJson = failureJson.call
						end

						format.json { render json: failureJson, status: :unprocessable_entity }
					end
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: unauthorizedStatus }
				end
			end
		end
	end
end
