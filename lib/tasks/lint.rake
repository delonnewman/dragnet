# frozen_string_literal: true

namespace :lint do
  desc 'Lint Ruby code with RuboCop'
  task ruby: :environment do
    sh 'bundle exec rubocop'
  end
end
