# frozen_string_literal: true

EDITOR_SOURCE_PATH = 'app/assets/javascripts/frontend'

namespace :frontend do
  desc 'start dev server for frontend'
  task :server do
    sh "cd #{EDITOR_SOURCE_PATH} && npx shadow-cljs watch frontend"
  end

  desc 'install frontend dependencies'
  task :deps do
    sh "npm install #{EDITOR_SOURCE_PATH}"
  end
end
