require_dependency "bespoke/application_controller"

module Bespoke
	class SubscriptionsController < ApplicationController
		after_action :verify_authorized, except: [:subscribed, :unsubscribed]
		before_action :set_subscription, only: [:unsubscribe, :destroy]

		def new
			@subscription = Subscription.new
			authorize @subscription
		end

		def subscribed
		end

		def unsubscribe
			authorize @subscription
		end

		def unsubscribed
		end

		def create
			@subscription = Subscription.new(subscription_params)

			authorize @subscription

			if antispam_params[:answer] == antispam_params[:solution]
				respond_to do |format|
					if @subscription.save
						format.html { redirect_to subscribed_path }
					else
						format.html { render :new }
					end
				end
			else
				@subscription.errors.add(:base, "Antispam question wasn't answered correctly")
				respond_to do |format|
					format.html { render :new }
				end
			end
		end

		def destroy
			authorize @subscription

			@subscription.destroy
			redirect_to unsubscribed_path, notice: "Successfully unsubscribed."
		end

		private

		def set_subscription
			@subscription = Subscription.from_token(params[:token])
		end

		# Only allow a trusted parameter "white list" through.
		def subscription_params
			params.require(:subscription).permit(:email)
		end

		def antispam_params
			params.require(:antispam).permit(:solution,
			                                 :answer)
		end
	end
end
