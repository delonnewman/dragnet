# frozen_string_literal: true

namespace :docs do
  desc 'Start yard doc server on port 8808'
  task serve: :environment do
    sh 'bundle exec rdoc --server=8808'
  end

  desc 'Generate API documentation'
  task generate: :environment do
    sh 'bundle exec rdoc --template=rorvswild `find {lib,app} -name *.rb`'
  end
end
