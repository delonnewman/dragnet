# frozen_string_literal: true

module Dragnet
  class Policy < Composed
    class << self
      alias policy_for new
      alias for new
    end
  end
end
