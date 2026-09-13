module Dragnet
  module Ext
    class Phone < Types::Text
      def render_answers_text(...) = RenderAnswersText.new(question, ...)
    end
  end
end
