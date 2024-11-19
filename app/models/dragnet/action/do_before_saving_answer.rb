module Dragnet
  class Action::DoBeforeSavingAnswer < Action
    attribute :answer
    attribute :question

    def text(type)
      return unless question.settings.long_answer? && question.settings.countable?

      answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
    end
  end
end
