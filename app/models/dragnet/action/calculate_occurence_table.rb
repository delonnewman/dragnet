module Dragnet
  class Action::CalculateOccurenceTable < Action
    attribute :reportable
    attribute :question

    def text(type)
      unless question.settings.long_answer? && question.settings.countable?
        raise "can't collect occurrence stats for text unless the setting is turned on"
      end

      reportable.answers.where(question:).group(:float_value).count
    end

    def number(type)
      if question.settings.decimal?
        reportable.answers.where(question:).group(:float_value).count
      else
        reportable.answers.where(question:).group(:integer_value).count
      end
    end

    def choice(type)
      opts = question.question_options.reduce({}) { |table, opt| table.merge!(opt.id => opt.text) }
      data = reportable.answers.where(question:).group(:question_option_id).count

      data.transform_keys(&opts)
    end
  end
end
