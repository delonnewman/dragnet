# frozen_string_literal: true

module SelfDescribable
  # @api private
  module Evaluation
    module_function

    def meta_attributes(key, value)
      case value
      when Array
        multi_meta_attributes(key, value)
      when Hash
        ref_meta_attributes(key, value)
      else
        [single_meta_attributes(key, value)]
      end
    end

    def multi_meta_attributes(key, values)
      values.map do |value|
        single_meta_attributes(key, value)
      end
    end

    def ref_meta_attributes(key, deref)
      deref.reduce([]) do |a, (k, v)|
        a << single_meta_attributes(key, k, type: :ref)
        if v.is_a?(Hash)
          ref_meta_attributes(k, v).each do |attr|
            a << attr
          end
          a
        else
          a << single_meta_attributes(k, v)
        end
      end
    end

    def single_meta_attributes(key, value, type: value.class)
      { key: key, value: String(value), key_type: type.name }
    end
  end
end
