# frozen_string_literal: true

EDITOR_SOURCE_PATH = 'app/assets/javascripts/editor'

namespace :editor do
  desc 'start dev server for survey editor'
  task :server do
    sh "cd #{EDITOR_SOURCE_PATH} && npx shadow-cljs watch frontend"
  end

  desc 'install editor dependencies'
  task :deps do
    sh "npm install #{EDITOR_SOURCE_PATH}"
  end
end
