namespace :deployment do
  namespace :build do
    desc 'Build assets for deployment (including frontend code)'
    task assets: %i[assets:precompile frontend:build]

    task all: %i[deploy:build:assets docker:image:build]
  end

  desc 'Perform a complete build of the system as a Docker image'
  task build: %i[deployment:build:all]

  desc 'Push image to container registry'
  task push: %i[docker:image:push]
end
