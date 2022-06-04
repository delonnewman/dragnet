Rails.application.routes.draw do
  root 'surveys#index'

  get 'report', to: 'reports#show'
end
