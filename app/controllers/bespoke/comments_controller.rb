require_dependency "bespoke/application_controller"

module Bespoke
	class CommentsController < ApplicationController
		before_action :authenticate_author, only: [:destroy]
		after_action :verify_authorized
		before_action :set_comment, only: [:update, :destroy]

		def create
			@comment = Comment.new(comment_params)

			begin
				authorize @comment

				subscription = nil
				params = subscription_params
				if params and params[:subscribe]
					subscription = @comment.post.subscriptions.build(email: params[:email])
				end

				respond_to do |format|
					errorMessages = Array.new
					if subscription and not subscription.valid?
						errorMessages += subscription.errors.full_messages
					end

					if not @comment.valid?
						errorMessages += @comment.errors.full_messages
					end

					if errorMessages.empty?
						if (subscription.nil? or (subscription and subscription.save)) and @comment.save
							format.json { render_comment_json(@comment) }
						else
							errorMessages += @comment.errors.full_messages

							if subscription
								errorMessages += subscription.errors.full_messages
							end
						end
					end

					unless errorMessages.empty?
						format.json { render json: errorMessages, status: :unprocessable_entity }
					end
				end
			rescue Pundit::NotAuthorizedError
				respond_to do |format|
					# Don't leak that the post actually exists. Turn the
					# "unauthorized" into a "not found"
					format.json { render json: true, status: :not_found }
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

		def subscription_params
			if params[:subscription]
				params.require(:subscription).permit(:subscribe,
			                                        :email)
			end
		end
	end
end
