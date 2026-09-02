module Dragnet
  module Ext
    class Link < Types::Text
      def render_answers_text(...) = RenderAnswersText.new(question, ...)
    end
  end
end
