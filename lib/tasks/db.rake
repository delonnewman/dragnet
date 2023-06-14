# frozen_string_literal: true

namespace :db do
  desc 'reset the database (i.e. db:drop_tables db:migrate db:seed)'
  task reset: %i[db:drop_tables db:migrate db:seed]

  desc 'drop all tables in the database'
  task drop_tables: :environment do
    config = Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.tap do |conn|
      conn.tables.each do |table|
        next unless conn.table_exists?(table)

        puts "Dropping table #{table}..."
        conn.drop_table(table, force: :cascade)
      end
    end
  end
end
