Bespoke::Engine.routes.draw do
	resources :posts
	resources :comments, only: [:create, :update, :destroy]
	resources :subscriptions, only: [:new, :create]

	get 'subscriptions/subscribed' => 'subscriptions#subscribed', as: :subscribed
	get 'subscriptions/unsubscribe' => 'subscriptions#unsubscribed', as: :unsubscribed
	get 'subscriptions/unsubscribe/:token' => 'subscriptions#unsubscribe', as: :unsubscribe
	delete 'subscriptions/unsubscribe/:token' => 'subscriptions#destroy'

	root 'posts#index'
end
