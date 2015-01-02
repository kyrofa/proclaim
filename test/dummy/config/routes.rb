Rails.application.routes.draw do
  mount Bespoke::Engine => "/bespoke"

  root 'bespoke/posts#index'
end
