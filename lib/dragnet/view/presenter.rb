module Dragnet
  module View
    class Presenter < SimpleDelegator
      include Memoizable
      include Dragnet

      class << self
        def presents(*target_classes, as: nil)
          self.presentable_classes = target_classes

          alias_method(as, :__getobj__) if as
        end

        attr_reader :presentable_classes

        private

        attr_writer :presentable_classes
      end

      attr_reader :params

      # @param [Object] obj
      # @param [ActionController::Parameters, Hash] params
      def initialize(obj, params = nil)
        super(obj)
        @params = params
      end
    end
  end
end
