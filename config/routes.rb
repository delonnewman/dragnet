Rails.application.routes.draw do
  devise_for :users, class_name: 'Dragnet::User'
  authenticate :user, -> (user) { user.admin? } do
    mount PgHero::Engine, at: 'pg'
  end
  
  root 'workspace#index'
  get 'surveys', to: 'workspace#surveys'
  get 'report', to: 'reports#show'
  get 'stats', to: 'stats#show'

  resources :surveys, only: %i[show create edit update destroy] do
    member do
      post 'copy',  to: 'surveys/copy#create'
      post 'open',  to: 'surveys/access#open'
      post 'close', to: 'surveys/access#close'
      get 'share',  to: 'surveys/sharing#show'
      get 'share/:method', to: 'surveys/sharing#show'
    end

    get 'qrcode', to: 'surveys/qr_code#show'
    get 'settings', to: 'surveys/settings#show'

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

  # survey name is optional
  get '/r/:survey_id/:survey_name', to: 'submission_request#new', as: 'reply_to'
  get '/r/:survey_id', to: 'submission_request#new'
  post '/r/:survey_id/:survey_name', to: 'submission_request#create'
  post '/r/:survey_id', to: 'submission_request#create'
  match '/reply/404', to: 'submission_request#not_found', as: :survey_not_found, via: :all
  match '/reply/403', to: 'submission_request#forbidden', as: :survey_forbidden, via: :all

  scope '/survey_editor/:survey_id', as: "survey_editor" do
    resource :details, only: %i[update], controller: 'survey_editor/details'
    resource :display_order, only: %[update], controller: 'survey_editor/display_order'
    resource :preview, only: %i[show edit update], controller: 'survey_editor/preview'
    resources :questions, except: %i[new edit index], controller: 'survey_editor/questions'
  end
end
