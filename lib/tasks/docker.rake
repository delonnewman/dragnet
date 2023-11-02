namespace :docker do
  desc 'build docker image'
  task image: :environment do
    sh 'docker build -t docker.io/delonnewman/dragnet:$(cat RELEASE.txt) -t docker.io/delonnewman/dragnet:latest .'
  end

  desc 'push docker image'
  task push: :environment do
    sh 'docker push -a docker.io/delonnewman/dragnet'
  end
end
