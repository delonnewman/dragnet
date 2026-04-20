class Dragnet
  module Typable
    attribute :type_class_name
    
    def type
      type_class&.new(self)
    end

    def type=(type)
      self.type_class = Dragnet::Type.find(type)
    end

    def type_class=(klass)
      self.type_class_name = klass.name
    end

    def type_class
      type_class_name&.constantize
    end
  end
end
