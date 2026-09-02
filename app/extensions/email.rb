module Dragnet
  module Ext
    class Email < Types::Text
      def render_answers_text(...) = RendersAnswersText.new(question, ...)
    end
  end
end
