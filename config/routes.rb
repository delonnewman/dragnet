Rails.application.routes.draw do
  root 'surveys#index'

  get 'report', to: 'reports#show'

  resources :reply, only: %i[new edit update] do
    get 'successful'
  end
end
