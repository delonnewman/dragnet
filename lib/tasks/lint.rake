# frozen_string_literal: true

namespace :lint do
  desc 'Lint Ruby code with RuboCop'
  task ruby: :environment do
    sh 'bundle exec rubocop -f emacs'
  end
end

namespace :format do
  desc 'Format Ruby code with RuboCop'
  task ruby: :environment do
    sh 'bundle exec rubocop -f emacs --auto-correct'
  end
end
