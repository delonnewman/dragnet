namespace :deploy do
  namespace :build do
    desc 'build assets for deployment (including frontend code)'
    task assets: %i[assets:precompile frontend:build]

    task all: %i[deploy:build:assets docker:image]
  end

  task build: %i[deploy:build:all]
end