source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'rails', '~> 7.0.3'

gem 'pg', '~> 1.1'

gem 'unicorn', require: false
gem 'webrick', group: :development

gem 'sprockets-rails'
gem 'bootstrap', '~> 5.1.3'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Use Sass to process CSS
# gem 'sassc-rails'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri]

  gem 'rspec'
  gem 'rspec-rails'

  gem 'gen-test', github: 'delonnewman/gen-test'

  gem 'brakeman'
  gem 'rubocop'
  gem 'rubocop-rails'
end

group :development do
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

