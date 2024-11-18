class Dragnet
  class Action::DoBeforeSavingAnswer < Action
    private attr_reader :answer, :question

    def initialize(answer:, question:)
      @answer = answer
      @question = question
    end

    # Do nothing by default
    def number(type); end
    def time(type); end
    def boolean(type); end
    def choice(type); end

    def text(type)
      return unless question.settings.long_answer? && question.settings.countable?

      answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
    end
  end
end
