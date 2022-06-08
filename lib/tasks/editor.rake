namespace :editor do
  desc 'start dev server for survey editor'
  task :server do
    sh 'cd editor && npx shadow-cljs watch frontend'
  end
end
