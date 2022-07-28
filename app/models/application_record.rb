class ApplicationRecord < ActiveRecord::Base
  include Dragnet
  extend  Dragnet::Advising

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

    delegate :generate!, :[], :generate, to: :generator
  end
end
