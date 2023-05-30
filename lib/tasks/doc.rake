namespace :doc do
  desc "Start yard doc server on port 8808"
  task :server do
    sh "bundle exec yard server -r -p 8808"
  end
end