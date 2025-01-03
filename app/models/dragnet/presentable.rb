module Dragnet
  module Presentable
    def present(with: nil)
      klass = presenter_class
      return self unless klass

      klass.new(self, with)
    end

    def presenter_class
      presenter_class_name.safe_constantize
    end

    def presenter_class_name
      "#{self.class.name}Presenter"
    end
  end
end
