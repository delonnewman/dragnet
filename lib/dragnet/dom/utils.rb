# frozen_string_literal: true

module Dragnet
  module DOM
    module Utils
      module_function

      # @param [Hash] styles
      # @return [String]
      def format_style_map(styles)
        styles.map do |(k, v)|
          v = v.is_a?(Numeric) ? "#{v}px" : v
          k = (k.is_a?(Symbol) ? k.name : k).tr('_', '-')
          "#{k}: #{v}"
        end.join('; ')
      end

      # @param [Hash] data
      # @return [Array<[String, String]>]
      def collect_data_attributes(data, prefix = 'data')
        data.map do |(key, value)|
          name = "#{prefix}-#{(key.is_a?(Symbol) ? key.name : key).tr('_', '-')}"
          [name, value.to_json]
        end
      end

      def format_data_attributes(data, prefix = 'data')
        collect_data_attributes(data, prefix).map do |(name, value)|
          Attribute.new(name: name, value: value).compile
        end.join(' ')
      end

      # @param [Array] class_list
      # @return [String]
      def format_class_list(class_list)
        class_list.join(' ')
      end
    end
  end
end
