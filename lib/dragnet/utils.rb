# frozen_string_literal: true

module Dragnet
  module Utils
    module_function

    def slug(string, delimiter: '-')
      string = string.is_a?(Symbol) ? string.name : string.to_s
      string = string.gsub(/\W+\z/, '')
      string.gsub!(/\A\W+/, '')
      string.gsub!(/\W+/, delimiter)
      string.downcase!

      string
    end
  end
end
