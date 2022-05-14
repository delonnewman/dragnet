# frozen_string_literal: true

module Dragnet
  module Utils
    module_function

    def slug(string, delimiter: '-')
      string.gsub(/\W+/, delimiter).downcase!
    end
  end
end
