# frozen_string_literal: true

module Dragnet
  module Utils
    module_function

    def slug(string, delimiter: '-')
      string = string.is_a?(Symbol) ? string.name : string.to_s
      string.gsub(/\W+/, delimiter).downcase!
    end
  end
end
