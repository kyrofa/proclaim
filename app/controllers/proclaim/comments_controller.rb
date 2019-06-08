#require_dependency "proclaim/application_controller"

module Proclaim
	class CommentsController < Proclaim::ApplicationController
		before_action :authenticate_author, only: [:destroy]
		after_action :verify_authorized
		before_action :set_comment, only: [:update, :destroy]

		def create
			@comment = Comment.new(comment_params)

			errors = Array.new
			options = Hash.new
			options[:success_json] = lambda {comment_json(@comment)}
			options[:failure_json] = lambda {errors}
			options[:operation] = lambda do
				if @comment.save
					return true
				else
					errors += @comment.errors.full_messages
					return false
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
			p = params.require(:comment).permit(
				:body, :author, :post_id, :parent_id,
				subscription_attributes: [:email])
			if params[:subscribe] && p.include?('subscription_attributes')
				p[:subscription_attributes].merge!({name: p[:author]})
			end
			p
		end

		def antispam_params
			params.require(:antispam).permit(:solution,
			                                 :answer)
		end
	end
end
