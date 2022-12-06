# frozen_string_literal: true

module Dragnet
  # A collection of utility functions for use within the appliction
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

    HASH_CODE_SEED = 80_447
    private_constant :HASH_CODE_SEED

    def hash_code(string)
      MurmurHash3::V32.str_hash(string, HASH_CODE_SEED)
    end

    def hash_combine(seed, hash)
      # a la boost, a la clojure
      seed ^ hash + 0x9e3779b9 + (seed << 6) + (seed >> 2)
    end
  end
end
