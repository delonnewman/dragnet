class ApplicationRecord < ActiveRecord::Base
  extend Dragnet::Composing
  include Dragnet

  primary_abstract_class

  class << self
    def generator_class_name
      "#{name}Generator"
    end

    def generator_class
      generator_class_name.safe_constantize
    end

    def generator
      generator_class || Dragnet::ActiveRecordGenerator.new(self)
    end

    def inherited(klass)
      super

      define_singleton_method(:[]) { |*args| generator[*args] }
      define_singleton_method(:generate) { |*args| generator.generate(*args) }
    end
  end
end
