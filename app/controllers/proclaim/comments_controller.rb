require_dependency "proclaim/application_controller"

module Proclaim
	class CommentsController < ApplicationController
		before_action :authenticate_author, only: [:destroy]
		after_action :verify_authorized
		before_action :set_comment, only: [:update, :destroy]

		def create
			@comment = Comment.new(comment_params)

			subscription = nil
			if subscription_params and subscription_params[:subscribe]
				subscription = Subscription.new(name: @comment.author,
				                                email: subscription_params[:email],
				                                post: @comment.post)
			end

			errors = Array.new
			options = Hash.new
			options[:success_json] = lambda {comment_json(@comment)}
			options[:failure_json] = lambda {errors}
			options[:operation] = lambda do
				respond_to do |format|
					begin
						# Wrap saving the comment in a transaction, so if the
						# subscription fails to save, the comment doesn't save either
						# (and vice-versa).
						Comment.transaction do
							@comment.save!

							if subscription
								subscription.save!
							end

							return true
						end
					rescue ActiveRecord::RecordInvalid
						errors += @comment.errors.full_messages

						if subscription
							errors += subscription.errors.full_messages
						end

						return false
					end
				end
			end

			# Don't leak that the post actually exists. Turn the "unauthorized"
			# into a "not found"
			options[:unauthorized_status] = :not_found

			handleJsonRequest(@comment, options) do
				if antispam_params[:answer] != antispam_params[:solution]
					respond_to do |format|
						format.json { render json: ["Antispam question wasn't answered correctly"], status: :unprocessable_entity }
					end
				end
			end
		end

		def update
			handleJsonRequest(@comment,
			                  operation: lambda {@comment.update(comment_params)},
			                  success_json: lambda {comment_json(@comment)})
		end

		def destroy
			handleJsonRequest(@comment) do
				@comment.destroy
			end
		end

		private

		def set_comment
			@comment = Comment.find(params[:id])
		end

		def comment_json(comment)
			return {
					id: comment.id,
					html: comment_to_html(comment)
			}
		end

		def comment_to_html(comment)
			view_context.comments_tree_for(comment.hash_tree)
		end

		# Only allow a trusted parameter "white list" through.
		def comment_params
			params.require(:comment).permit(:body,
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

		def antispam_params
			params.require(:antispam).permit(:solution,
			                                 :answer)
		end
	end
end
