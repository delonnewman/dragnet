Rails.application.routes.draw do
  root 'forms#index'

  get 'report', to: 'reports#show'
  get 'stats', to: 'stats#show'

  resources :forms, only: %i[index new edit] do
    get 'results'
    get 'stats', to: 'stats#show'
  end

  resources :responses, only: %i[edit update] do
    get 'success'
  end

  # survey name is optional
  get '/reply/to/:form_id/:form_name', to: 'responses#new', as: 'reply_to'
  get '/reply/to/:form_id', to: 'responses#new'

  scope '/api/v1/editing' do
    resources :form_editor, path: '/forms', only: %i[show update]
    post '/forms/:id/apply', to: 'form_editor#apply', as: 'form_editor_apply'
  end
end
