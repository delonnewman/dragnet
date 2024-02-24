# frozen_string_literal: true

FRONTEND_SOURCE_PATH = 'app/assets/javascripts/frontend'

namespace :frontend do
  desc 'Start dev server for frontend'
  task server: :environment do
    sh "cd #{FRONTEND_SOURCE_PATH} && npm run watch"
  end

  desc 'Install frontend dependencies'
  task deps: :environment do
    sh "cd #{FRONTEND_SOURCE_PATH} && npm install"
  end

  desc 'Build frontend for production'
  task build: :clean do
    sh "cd #{FRONTEND_SOURCE_PATH} && npm run build"
  end

  desc 'Remove frontend code'
  task clean: :environment do
    sh 'rm -rf public/js/editor && rm -rf public/js/submitter'
  end
end
