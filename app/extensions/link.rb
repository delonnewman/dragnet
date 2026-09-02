module Dragnet
  module Ext
    class Link < Types::Text
      def render_answers_text(...) = RenderAnswersText.new(question, ...)

      def build_value(answer)
        Value.new(answer.short_text_value)
      end

      def assign_value(answer, value)
        answer.short_text_value = value.to_s
      end

      class Value < Dragnet::Value
        def initialize(value)
          @value = value
          freeze
        end

        def text_value
          @value
        end
      end
    end
  end
end
