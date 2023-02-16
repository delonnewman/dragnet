# frozen_string_literal: true

module Dragnet
  module SelfDescribing
    def class_doc(doc = nil)
      return metadata[:doc] unless doc

      class_meta(doc: doc)
    end

    alias module_doc class_doc

    def class_meta(data)
      @metadata = data
    end

    alias module_meta class_meta

    def metadata
      meta = @metadata || {}

      if @method_metadata
        meta.merge(methods: @method_metadata)
      else
        meta
      end
    end

    def doc(doc)
      meta(doc: doc)
    end

    def meta(data)
      @_metadata = data
    end

    def add_method_metadata(method, data)
      @method_metadata ||= {}
      @method_metadata[method] = data
    end

    def method_metadata(method = nil)
      return @method_metadata unless method

      @method_metadata[method]
    end

    def method_added(method)
      super

      add_method_metadata(method, @_metadata)

      @_metadata = nil
    end
  end
end
