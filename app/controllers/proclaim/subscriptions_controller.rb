#require_dependency "proclaim/application_controller"

module Proclaim
	class SubscriptionsController < Proclaim::ApplicationController
		after_action :verify_authorized
		after_action :verify_policy_scoped, only: :index
		before_action :set_subscription, only: [:show, :edit, :update, :destroy]

		def index
			@subscriptions = policy_scope(Subscription).order(:comment_id, :name)
			authorize Subscription
		end

		def new
			@subscription = Subscription.new
			authorize @subscription
		end

		def show
			authorize @subscription
		end

		def create
			@subscription = Subscription.new(subscription_params)

			authorize @subscription

			if antispam_params[:answer] == antispam_params[:solution]
				respond_to do |format|
					if @subscription.save
						format.html {
							redirect_to subscription_path(@subscription.token),
							            notice: "Thanks for subscribing! You should "\
							                    "receive a confirmation email soon."
						}
					else
						format.html { render :new }
					end
				end
			else
				@subscription.errors.add(:base,
				                         "Antispam question wasn't answered "\
				                         "correctly")
				respond_to do |format|
					format.html { render :new }
				end
			end
		end

		def destroy
			authorize @subscription
			@subscription.destroy

			respond_to do |format|
				format.html {
					if current_author
						redirect_to subscriptions_path,
					               notice: "Subscription was successfully destroyed."
					else
						redirect_to posts_path,
					               notice: "Successfully unsubscribed. Sorry to "\
					                       "see you go!"
					end
				}
			end
		end

		private

		def set_subscription
			@subscription = Subscription.from_token(params[:token])
		end

		# Only allow a trusted parameter "white list" through.
		def subscription_params
			params.require(:subscription).permit(:name, :email)
		end

		def antispam_params
			params.require(:antispam).permit(:solution,
			                                 :answer)
		end
	end
end
