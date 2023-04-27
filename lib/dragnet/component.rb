# frozen_string_literal: true

module Dragnet
  class Component < DOM::Element
    class << self
      def html(&block)
        return @html if @html
        raise ArgumentError, 'a block is required' unless block_given?

        builder = DOM::HTMLDOMBuilder.new(self)
        @html = builder.instance_exec(&block)
      end

    end

    def initialize(**attributes)
      super(attributes: attributes)
    end

    def html
      ERB.new(self.class.html.to_s).result(binding)
    end
    alias to_s html

    def name
      self.class.name.split('::').last.dasherize
    end
  end
end
