# frozen_string_literal: true

FRONTEND_SOURCE_PATH = 'app/assets/javascripts/frontend'

namespace :frontend do
  desc 'start dev server for frontend'
  task server: :environment do
    sh "cd #{FRONTEND_SOURCE_PATH} && npm run watch"
  end

  desc 'install frontend dependencies'
  task deps: :environment do
    sh "npm install #{FRONTEND_SOURCE_PATH}"
  end

  desc 'build frontend for production'
  task build: :clean do
    sh "cd #{FRONTEND_SOURCE_PATH} && npm run build"
  end

  desc 'remove frontend code'
  task clean: :environment do
    sh 'rm -rf public/js/editor && rm -rf public/js/submitter'
  end
end
