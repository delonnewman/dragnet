module Dragnet
  module Ext
    class Address < Types::Text
      def do_before_saving_answer(...) = DoBeforeSavingAnswer.new(question, ...)
      def render_answers_text(...)     = RenderAnswersText.new(question, ...)
      def get_number_value(...)        = GetNumerValue.new(question, ...)

      def build_value_from_answer(answer)
        build_value_from_reply(answer.reply)
      end

      def build_value_from_reply(reply)
        answers = reply.answers_to(question)
        lat     = answers.find { it.short_text_value && it.float_value }
        long    = answers.find { !it.short_text_value && it.float_value }

        position = (if lat && long
                      Position.new(latitude: lat.float_value,
                                   longitude: long.float_value)
                    end)

        text     = lat.long_text_value
        province = lat.short_text_value
        country  = long&.short_text_value

        Value.new(text:, position:, province:, country:)
      end

      class Value < Dragnet::Value
        attr_reader :text, :position, :province, :country # : String # : ?Dragnet::Ext::Address::Position # : ?String # : ?String

        def initialize(text:, position: nil, province: nil, country: nil)
          @text     = text
          @position = position
          @province = province
          @country  = country
          freeze
        end

        alias state province

        def text_value
          @text
        end

        def to_a
          @position&.to_a
        end

        def to_h
          @position&.to_h
        end
      end

      Position = Data.define(:latitude, :longitude) do
        def to_a
          [latitude, longitude]
        end
      end
    end
  end
end
