Bespoke::Engine.routes.draw do
	resources :posts
	resources :comments, only: [:create, :destroy]

	root 'posts#index'
end
