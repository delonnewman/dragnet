# frozen_string_literal: true

module Dragnet
  module Memoizable
    def self.included(base)
      base.prepend(MemoWise)
      class << base
        alias memoize memo_wise
      end
    end
  end
end
