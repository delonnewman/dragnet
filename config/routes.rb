Rails.application.routes.draw do
  devise_for :users
  root 'workspace#index'

  get 'report', to: 'reports#show'
  get 'stats', to: 'stats#show'

  resources :surveys do
    get 'results'
    post 'copy'
    get 'stats', to: 'stats#show'
    get 'preview'
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
      get '/replies/:survey_id/preview', to: 'reply_submission#preview', as: 'preview_reply'
    end
  end
end
