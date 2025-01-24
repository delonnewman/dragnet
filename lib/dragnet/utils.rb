# frozen_string_literal: true

module Dragnet
  # A collection of utility functions for use within the application
  module Utils
    module_function

    # Generate a slug from string with all non safe and space characters replaced by the delimiter
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

    UUID_PATTERN = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
    private_constant :UUID_PATTERN

    def uuid?(string)
      return false unless string

      !!(string =~ UUID_PATTERN)
    end

    # Generate a UUID with a tag
    #
    # @example
    #  Dragnet::Utils.tagged_uuid("question") # => "question_P2c7p-lh3_mzskc7JE4SH"
    #
    # @params [String] tag
    #
    # @return [String]
    def tagged_uuid(tag)
      "#{tag}_#{short_uuid}"
    end

    def short_uuid
      shorten_uuid(uuid)
    end

    def uuid
      SecureRandom.uuid
    end

    ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.chars.freeze
    private_constant :ALPHABET

    def shorten_uuid(uuid)
      ShortUUID.shorten(uuid, ALPHABET)
    end

    def expand_short_uuid(short_uuid)
      ShortUUID.expand(short_uuid, ALPHABET)
    end
  end
end
