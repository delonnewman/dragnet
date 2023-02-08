require 'securerandom'

module Dragnet
  class UUID < Generator
    def call(*)
      SecureRandom.uuid
    end
  end
end