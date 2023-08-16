namespace :docker do
  desc 'build docker image'
  task :image do
    sh "docker build -t docker.io/delonnewman/dragnet:$(cat RELEASE.txt) -t docker.io/delonnewman/dragnet:latest ."
  end

  task :push do
    sh "docker push -a docker.io/delonnewman/dragnet"
  end
end