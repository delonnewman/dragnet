source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.2.1'

gem 'pg', '~> 1.1'
gem 'activerecord-like'
gem 'activerecord-pull-alpha'
gem 'mini_sql'

# HTTP
gem 'puma'
gem 'rack-cors'

# UI / Assets
gem 'bootstrap', '~> 5.2.3'
gem 'font-awesome-sass'
gem 'sprockets-rails'

gem 'chartkick'
# gem 'mapkick-rb' TODO: add location type

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

# Analytics
gem 'ahoy_matey'

# Performance
gem 'oj'
gem 'fast_blank'
gem 'erubi'

# Language Extensions
gem 'invokable'
gem 'memo_wise'
gem 'rails-pattern_matching'

# Data
gem 'faker'
gem 'sentimental'

# TODO: Move to Dart Sass
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

gem 'el-toolkit', require: 'el/data_utils', github: 'delonnewman/el-toolkit'

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false

  gem 'rails-controller-testing'
end

group :development, :test do
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
end

group :development do
  gem 'web-console'

  gem 'rack-mini-profiler'

  gem "rails_live_reload"

  gem 'yard'
  gem 'yard-activerecord'
  gem 'yardstick'
  gem 'yard-rspec'

  gem 'dockerfile-rails'

  gem 'rubocop'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-performance', require: false
end
