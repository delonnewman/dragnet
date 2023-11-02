# frozen_string_literal: true

namespace :doc do
  desc 'Start yard doc server on port 8808'
  task server: :environment do
    sh 'bundle exec yard server -r -p 8808 --plugin yard-rspec'
  end
end
