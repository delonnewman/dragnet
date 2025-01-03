module Dragnet
  class DoBeforeSavingAnswer < GenericFunction
    attribute :answer
    attribute :question

    def text
      return unless type.calculate_sentiment?(question)

      answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
    end
  end
end
