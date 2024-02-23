namespace :docker do
  namespace :image do
    desc 'Build docker image'
    task build: :environment do
      sh "docker build -t ghcr.io/delonnewman/dragnet:#{Dragnet.release}" \
         " -t ghcr.io/delonnewman/dragnet:#{Dragnet.version} -t docker.io/delonnewman/dragnet:latest ."
    end

    desc 'Push docker image'
    task push: :environment do
      sh 'docker push -a ghcr.io/delonnewman/dragnet'
    end

    desc 'Build and push docker image to container registry'
    task deploy: %i[build push]
  end

  namespace :container do
    desc 'Create a container from the most recently built image'
    task create: :environment do
      sh 'docker container create --name dragnet -p 3000:3000 ' \
         "--env-file .env ghcr.io/delonnewman/dragnet:#{Dragnet.version}"
    end

    desc 'Start an already created container'
    task start: :environment do
      sh 'docker container start dragnet'
    end

    desc 'Start an already created container'
    task stop: :environment do
      sh 'docker container stop dragnet'
    end

    desc 'Start an already created container'
    task remove: :environment do
      sh 'docker container rm dragnet'
    end
  end
end
