# frozen_string_literal: true

module Dragnet
  class Perspective
    class BeforeSavingAnswer < Perspective
      def update(_answer, _question)
        # do nothing
      end

      class Text < self
        def update(answer, question)
          return unless question.settings.long_answer? && question.settings.countable?

          answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
        end
      end
    end
  end
end
