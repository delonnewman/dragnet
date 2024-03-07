# frozen_string_literal: true

module Dragnet
  class Perspective
    class AnswerOccurrence < Perspective
      class Choice < self
        def collect(reportable, question)
          opts = question.question_options.reduce({}) { |table, opt| table.merge!(opt.id => opt.text) }
          data = reportable.answers.where(question:).group(:question_option_id).count

          data.transform_keys(&opts)
        end
      end

      class Number < self
        def collect(reportable, question)
          if question.settings.decimal?
            reportable.answers.where(question:).group(:float_value).count
          else
            reportable.answers.where(question:).group(:integer_value).count
          end
        end
      end

      class Text < self
        def collect(reportable, question)
          reportable.answers.where(question:).group(:float_value).count
        end
      end
    end
  end
end
