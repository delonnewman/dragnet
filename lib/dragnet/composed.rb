# frozen_string_literal: true

module Dragnet
  class Composed
    attr_reader :subject

    def initialize(subject)
      @subject = subject
    end
  end
end
