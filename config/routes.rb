Proclaim::Engine.routes.draw do
	resources :posts
	resources :comments, only: [:create, :update, :destroy]

	# Subscription administration is authenticated via tokens
	resources :subscriptions, param: :token, except: [:edit, :update]

	root 'posts#index'
	default_url_options Rails.application.config.action_mailer.default_url_options
end
