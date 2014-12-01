Bespoke::Engine.routes.draw do
	resources :posts
	resources :comments, only: [:create, :update, :destroy]

	root 'posts#index'
end
