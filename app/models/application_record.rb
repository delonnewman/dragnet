class ApplicationRecord < ActiveRecord::Base
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

      klass.extend(SingleForwardable)
      klass.def_delegators(:generator, :[], :generate)
    end
  end
end
