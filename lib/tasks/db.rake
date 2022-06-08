namespace :db do
  desc 'reset the database (i.e. db:drop db:create db:migrate db:seed)'
  task reset: %i[db:drop db:create db:migrate db:seed]
end
