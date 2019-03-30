Proclaim::Engine.routes.draw do
	resources :posts

	resources :images, only: [:create, :destroy]
	post 'images/cache' => 'images#cache', as: :cache_image
	post 'images/discard' => 'images#discard', as: :discard_image

	resources :comments, only: [:create, :update, :destroy]

	# Subscription administration is authenticated via tokens
	resources :subscriptions, param: :token, except: [:edit, :update]

	root 'posts#index'
end
