# frozen_string_literal: true

module Dragnet
  class TextSentiment
    class << self
      def analyzer
        @analyzer ||= Sentimental.new.tap(&:load_defaults)
      end
    end

    attr_reader :text

    def initialize(text)
      @text = text.frozen? ? text : text.dup.freeze
    end

    def score
      @score ||= analyzer.score(text)
    end
    alias to_f score

    def percentage
      score * 100
    end

    def to_s
      format('%<percent>.1f%% positive - "%<text>s"', percent: percentage.round(1), text: text)
    end
    alias inspect to_s

    delegate :analyzer, to: 'self.class'
    private :analyzer
  end
end
