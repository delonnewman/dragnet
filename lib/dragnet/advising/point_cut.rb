# frozen_string_literal: true

module Dragnet
  module Advising
    class PointCut
      attr_reader :name, :advice, :args, :delegate_methods, :options

      def initialize(attributes)
        @name, @advice, @args, @delegate_methods, @options =
          attributes.values_at(:name, :advice, :args, :delegate_methods, :options)
      end

      def method_name
        return @name if @name
        raise "can't generate method name for anonymous class" unless advice.name

        advice.name.split('::').last.underscore.to_sym
      end
    end
  end
end
