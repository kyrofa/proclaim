require_dependency "bespoke/application_controller"

module Bespoke
	class CommentsController < ApplicationController
		before_action :authenticate_author, only: [:destroy]
		after_action :verify_authorized
		before_action :set_comment, only: [:update, :destroy]

		def create
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

		def update
			begin
				authorize @comment

				respond_to do |format|
					if @comment.update(comment_params)
						format.json { render_comment_json(@comment) }
					else
						format.json { render json: @comment.errors.full_messages, status: :unprocessable_entity }
					end
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		def destroy
			begin
				authorize @comment

				respond_to do |format|
					@comment.destroy
					format.json { render json: true, status: :ok }
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					format.json { render json: true, status: :unauthorized }
				end
			end
		end

		private

		def set_comment
			@comment = Comment.find(params[:id])
		end

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
