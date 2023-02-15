# frozen_string_literal: true

module Dragnet
  class Policy
    class << self
      alias policy_for new
      alias for new
    end

    attr_reader :subject

    def initialize(subject)
      @subject = subject
    end
  end
end
