# frozen_string_literal: true

namespace :docs do
  desc 'Start yard doc server on port 8808'
  task serve: :environment do
    sh 'bundle exec yard server -r -p 8808 --plugin yard-rspec'
  end

  desc 'Generate API documentation'
  task generate: %i[environment frontend:docs] do
    sh 'bundle exec yard doc `find {lib,app} -name *.rb`'
  end
end
