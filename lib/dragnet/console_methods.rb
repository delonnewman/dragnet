# frozen_string_literal: true

module Dragnet
  module ConsoleMethods
    def s(index = 0, id: nil)
      sample_record Dragnet::Survey, index, id:
    end

    def u(index = 0, id: nil)
      sample_record Dragnet::User, index, id:
    end

    def sample_record(klass, index = 0, id: nil)
      return klass.find(id) if id

      @ids ||= {}
      @ids[klass] ||= klass.ids

      @this ||= {}
      @this[klass] ||= []
      @this[klass][index] ||= klass.find(@ids[klass].sample)
    end
  end
end
