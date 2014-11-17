require_dependency "bespoke/application_controller"

module Bespoke
	class CommentsController < ApplicationController
		before_action :authenticate_author, only: [:destroy]

		def create
			@comment = Comment.new(comment_params)

			@comment.post_id = params[:post_id]
			@comment.parent_id = params[:parent_id]

			respond_to do |format|
				if @comment.save
					format.js {}
				else
					format.js {}
				end
			end
		end

		private

		# Only allow a trusted parameter "white list" through.
		def comment_params
			params.require(:comment).permit(:title,
			                                :body,
			                                :author)
		end
	end
end
