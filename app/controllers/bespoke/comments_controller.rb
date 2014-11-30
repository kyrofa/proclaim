require_dependency "bespoke/application_controller"

module Bespoke
	class CommentsController < ApplicationController
		before_action :authenticate_author, only: [:destroy]
		after_action :verify_authorized

		def create
			sleep 3
			@comment = Comment.new(comment_params)
			authorize @comment

			respond_to do |format|
				if @comment.save
					format.json { render_comment_json(@comment) }
				else
					format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
				end
			end
		end

		def destroy
			@comment = Comment.find(params[:id])

			respond_to do |format|
				@comment.destroy
				format.json { render json: true, status: :ok }
			end
		end

		private

		def render_comment_json(comment)
			render json: {
				id: comment.id,
				html: comment_to_html(comment)
			}
		end

		def comment_to_html(comment)
			view_context.comments_tree_for(comment.hash_tree)
		end

		# Only allow a trusted parameter "white list" through.
		def comment_params
			params.require(:comment).permit(:title,
			                                :body,
			                                :author,
			                                :post_id,
			                                :parent_id)
		end
	end
end
