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
    end
  end
end
