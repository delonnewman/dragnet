module Dragnet
  class Continuation
    attr_reader :id, :params

    delegate :[], :key?, to: :params

    def initialize(params)
      @id = Utils.short_uuid
      @params = params.to_h
      freeze
    end
  end
end
