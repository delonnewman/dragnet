Rails.application.routes.draw do
  root 'surveys#index'

  get 'report', to: 'reports#show'

  get 'stats', to: 'stats#show'
  get 'surveys/:survey_id/stats', to: 'stats#show', as: 'survey_stats'

  resources :reply, only: %i[edit update] do
    get 'success'
  end

  # survey name is optional
  get '/reply/to/:survey_id/:survey_name', to: 'reply#new', as: 'reply_to'
  get '/reply/to/:survey_id', to: 'reply#new'
end
