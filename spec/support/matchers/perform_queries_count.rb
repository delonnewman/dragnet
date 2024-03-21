# Counts the number of SQL performed by a block. Useful for testing N+1s.
#
# Usage:
# expect { ... }.to perform_queries_count(1)
#
# (see https://medium.com/@esperonleticia/rspec-matcher-to-identify-n-1-queries-62986d019a45)
RSpec::Matchers.define :perform_number_of_queries do |expected_count|
  supports_block_expectations

  match do |block|
    @data = []
    query_counter = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      @query_count += 1
      @data << payload
    end

    @query_count = 0
    block.call
    ActiveSupport::Notifications.unsubscribe(query_counter)

    @query_count == expected_count
  end

  failure_message do |_block|
    msg = "expected to perform #{expected_count} SQL queries, but did #{@query_count}:\n"
    @data.each do |payload|
      binds = payload[:binds].map(&:value)
      msg << "  #{payload[:name]}: #{payload[:sql]}, #{binds.inspect}\n"
    end
    msg
  end
end
