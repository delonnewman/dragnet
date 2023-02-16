source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

gem 'rails', '~> 7.0.4.2'

gem 'pg', '~> 1.1'
gem 'activerecord-pull-alpha'
gem 'mini_sql'

# HTTP
gem 'puma', group: :development
gem 'rack-cors'
gem 'unicorn', require: false

# UI / Assets
gem 'bootstrap', '~> 5.1.3'
gem 'font-awesome-sass'
gem 'sprockets-rails'

gem 'chartkick'
gem 'mapkick-rb'
gem 'bumpspark'

gem 'pry'
gem 'pry-rails'

# Encoding / Data Formats
gem 'murmurhash3'
gem 'shortuuid'
gem 'transit-ruby', require: 'transit'
gem 'rqrcode'

gem 'pagy'

gem 'devise'
gem 'omniauth', '~> 2.1.1'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-apple'

gem 'fast_blank'

# Language Extentions
gem 'invokable'
gem 'memo_wise'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Use Sass to process CSS
gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri]

  gem 'rspec'
  gem 'rspec-rails'

  gem 'guard', require: false
  gem 'guard-rspec', require: false

  gem 'gen-test', github: 'delonnewman/gen-test'

  gem 'brakeman'
  gem 'bullet'
  gem 'bundler-audit'

  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'

  gem 'faker'
end

group :development do
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'

  gem 'yard'
  gem 'yard-activerecord'
end
