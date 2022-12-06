# frozen_string_literal: true

module Configurable
  extend ActiveSupport::Concern

  included do
    serialize :settings
  end

  class_methods do
    def setting(name, default: nil)
      define_method name do
        settings.fetch(name, default)
      end

      define_method "#{name}?" do
        settings.key?(name)
      end
    end
  end
end
