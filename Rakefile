require_relative "config/application"

if Rails.env.development?
  require 'bundler/audit/task'
  Bundler::Audit::Task.new
end

Rails.application.load_tasks
