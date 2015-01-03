Rails.application.routes.draw do
  mount Proclaim::Engine => "/proclaim"

  root 'proclaim/posts#index'
end
