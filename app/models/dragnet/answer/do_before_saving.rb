module Dragnet
  class Answer::DoBeforeSaving < TypeMethod
    attribute :answer
    attribute :question

    def long_text
      return unless type.calculate_sentiment?(question)

      answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
    end
  end
end
