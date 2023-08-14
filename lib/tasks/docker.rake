namespace :docker do
  desc 'build docker image'
  task :image do
    sh "docker build -t dragnet ."
  end
end