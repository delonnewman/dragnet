# frozen_string_literal: true

module Dragnet
  # A collection of utility functions for use within the application
  module Utils
    module_function

    # Generate a slug from string with all non safe and space characters replaced by the delimiter
    # @api public
    #
    # @example
    #   Dragnet::Utils.slug("$%`Hey`there") # => "hey-there"
    #
    # @param [String] string
    # @param [String] delimiter
    #
    # @return [String]
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

    # Return a murmur string hash of the string
    # @api public
    #
    # @param [String] string
    #
    # @return [String]
    def hash_code(string)
      MurmurHash3::V32.str_hash(string, HASH_CODE_SEED)
    end

    # @api public
    # @param [Integer] seed
    # @param [Integer] hash
    #
    # @return [Integer] the combined hash
    def hash_combine(seed, hash)
      # a la boost, a la clojure
      seed ^ hash + 0x9e3779b9 + (seed << 6) + (seed >> 2)
    end
  end
end
