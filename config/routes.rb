Bespoke::Engine.routes.draw do
	resources :posts do
		post 'comments/new(/:parent_id)' => 'comments#create', as: :comments
	end

	root 'posts#index'
end
