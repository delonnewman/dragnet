source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '~> 7.0.4.3'

gem 'pg', '~> 1.1'
gem 'activerecord-like'
gem 'activerecord-pull-alpha'
gem 'mini_sql'

# HTTP
gem 'puma', group: :development
gem 'rack-cors'
gem 'unicorn', require: false

# UI / Assets
gem 'bootstrap', '~> 5.2.3'
gem 'font-awesome-sass'
gem 'sprockets-rails'

gem 'chartkick'
gem 'mapkick-rb'

gem 'pry'
gem 'pry-rails'

# Encoding / Data Format
gem 'murmurhash3'
gem 'rqrcode'
gem 'shortuuid'
gem 'transit-ruby', require: 'transit'
gem 'transit-rails'

gem 'pagy'

# User data formats
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'csv_builder'

# Authentication
gem 'devise'
gem 'omniauth', '~> 2.1.1'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-apple'

# Performance
gem 'oj'
gem 'fast_blank'
gem 'erubi'

# Language Extensions
gem 'invokable'
gem 'memo_wise'
gem 'rails-pattern_matching'

# TODO: Move to Dart Sass
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

git 'https://github.com/delonnewman/el-toolkit.git' do
  gem 'el-core', require: 'el/data_utils'
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri]
  gem 'pry-stack_explorer'

  gem 'rspec'
  gem 'rspec-rails'

  gem 'guard', require: false
  gem 'guard-rspec', require: false

  gem 'gen-test', github: 'delonnewman/gen-test'

  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'

  # markdown lint
  gem 'mdl', require: false

  gem 'rubocop'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-performance', require: false

  gem 'simplecov', require: false

  gem 'faker'
end

group :development do
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'

  gem "rails_live_reload"

  gem 'yard'
  gem 'yard-activerecord'
  gem 'yardstick'
  gem 'yard-rspec'

  gem 'dockerfile-rails'
end
