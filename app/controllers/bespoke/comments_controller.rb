require_dependency "bespoke/application_controller"

module Bespoke
	class CommentsController < ApplicationController
		before_action :authenticate_author only: [:destroy]

		def index
			@comments = Comment.all
		end
	end
end
