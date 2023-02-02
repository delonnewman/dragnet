Rails.application.routes.draw do
  root 'surveys#index'

  get 'report', to: 'reports#show'
  get 'stats', to: 'stats#show'

  # OmniAuth
  post 'auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new'

  resources :surveys, only: %i[index new edit] do
    get 'results'
    get 'stats', to: 'stats#show'
  end

  resources :reply, only: %i[edit update] do
    get 'success'
  end

  # survey name is optional
  get '/reply/to/:survey_id/:survey_name', to: 'reply#new', as: 'reply_to'
  get '/reply/to/:survey_id', to: 'reply#new'

  scope '/api/v1' do
    scope '/editing' do
      resources :survey_editor, path: '/surveys', only: %i[show update]
      post '/surveys/:id/apply', to: 'survey_editor#apply', as: 'survey_editor_apply'
    end

    scope '/submission' do
      resources :reply_submission, path: '/replies', only: %i[show]
      post '/replies/:id/submit', to: 'reply_submission#submit', as: 'submit_reply'
    end
  end
end
