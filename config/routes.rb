Rails.application.routes.draw do
  devise_for :users, class_name: 'Dragnet::User'
  root 'workspace#index'

  get 'surveys', to: 'workspace#surveys'
  get 'report', to: 'reports#show'
  get 'stats', to: 'stats#show'

  resources :surveys, only: %i[show new edit destroy] do
    member do
      post 'copy'
      post 'open'
      post 'close'
      get 'preview'
      get 'share'
      get 'share/:method', to: 'surveys#share'
    end

    get 'qrcode'
    get 'settings'

    get 'stats', to: 'stats#show'

    get 'data', to: 'data_grid#show'
    get 'data/rows', to: 'data_grid#rows'
    get 'data/table', to: 'data_grid#table'

    get 'changes', to: 'record_changes#index'
  end

  resources :replies, only: %i[edit update] do
    member do
      get 'complete'
      post 'submit'
    end
  end
  get '/reply/:survey_id/preview', to: 'replies#preview'

  # survey name is optional
  get '/r/:survey_id/:survey_name', to: 'submission_request#new', as: 'reply_to'
  get '/r/:survey_id', to: 'submission_request#new'
  get '/reply/:survey_id', to: 'submission_request#new'

  scope '/api/v1', defaults: { format: :transit } do
    scope '/editing' do
      resources :survey_editor, path: '/surveys', only: %i[show update]
      post '/surveys/:id/apply', to: 'survey_editor#apply', as: 'survey_editor_apply'
    end

    scope '/submission' do
      resources :reply_submission, path: '/replies', only: %i[show]

      post '/replies/:survey_id', to: 'reply_submission#new', as: 'new_reply' # for generating a reply through the API
      get '/replies/:survey_id/preview', to: 'reply_submission#preview', as: 'preview_reply'
    end
  end
end
