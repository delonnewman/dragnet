source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

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
gem 'mapkick-rb'

# Encoding / Data Format
gem 'murmurhash3'
gem 'rqrcode'
gem 'shortuuid'
gem 'transit-ruby', github: 'delonnewman/transit-ruby'
gem 'transit-rails'

gem 'pagy'

# User data formats
gem 'csv'
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

gem 'el-toolkit', require: 'el/data_utils', github: 'delonnewman/el-toolkit'

gem 'mail'

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false

  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'

  gem 'gen-test', github: 'delonnewman/gen-test'

  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'
end

group :development do
  gem 'web-console'

  gem "rails_live_reload"
  gem 'rack-mini-profiler'

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
