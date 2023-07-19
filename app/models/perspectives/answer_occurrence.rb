# frozen_string_literal: true

module Perspectives
  class AnswerOccurrence < BasePerspective
    class Choice < self
      def collect(reportable, question)
        opts = question.question_options.reduce({}) { |table, opt| table.merge!(opt.id => opt.text) }
        data = reportable.answers.where(question: question).group(:question_option_id).count

        data.transform_keys(&opts)
      end
    end

    class Number < self
      def collect(reportable, question)
        if question.settings.decimal?
          reportable.answers.where(question: question).group(:float_value).count
        else
          reportable.answers.where(question: question).group(:integer_value).count
        end
      end
    end
  end
end
