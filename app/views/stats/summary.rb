module Dragnet::Views::Stats
  class Summary < Dragnet::Views::Base
    include Phlex::Rails::Helpers::Chartkick

    def initialize(report:)
      @report = report
    end

    def view_template
      div(class: 'container') do
        render Table.new(report: @report)

        div(class: 'mt-5 pb-5 border-bottom') do
          h2 { plain 'Replies By Day' }
          line_chart @report.replies_by_date
        end

        div(class: 'mt-5 pb-5 border-bottom') do
          h2 { plain 'Replies By Month' }
          line_chart @report.replies_by_month
        end

        div(class: 'mt-5 pb-5 border-bottom') do
          h2 { plain 'Replies By Day Of Week' }
          line_chart @report.replies_by_weekday
        end

        div(class: 'mt-5 pb-5 border-bottom') do
          h2 { plain 'Replies By Time Of Day' }
          line_chart @report.replies_by_time_of_day
        end

        @report.countable_questions.each do |question|
          div(class: 'mt-5 pb-5') do
            h2 { plain question.text }
            auto_chart @report.answer_occurrence(question)
          end
        end
      end
    end

    def auto_chart(data)
      if data.size < 5
        pie_chart(data)
      else
        column_chart(data)
      end
    end
  end
end
