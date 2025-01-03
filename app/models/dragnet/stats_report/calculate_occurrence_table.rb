module Dragnet
  class StatsReport::CalculateOccurrenceTable < GenericFunction
    attribute :reportable
    attribute :question

    def text
      unless type.calculate_sentiment?(question)
        raise "can't collect occurrence stats for text unless the setting is turned on"
      end

      reportable.answers.where(question:).group(:float_value).count
    end

    def number
      if question.settings.decimal?
        reportable.answers.where(question:).group(:float_value).count
      else
        reportable.answers.where(question:).group(:integer_value).count
      end
    end

    def choice
      opts = question.question_options.reduce({}) { |table, opt| table.merge!(opt.id => opt.text) }
      data = reportable.answers.where(question:).group(:question_option_id).count

      data.transform_keys(&opts)
    end
  end
end
