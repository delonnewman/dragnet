# frozen_string_literal: true

module Dragnet
  module DOM
    module Tags
      # @api private
      def registered_tags
        @registered_tags ||= Concurrent::Map.new
      end

      def register_tag(method_name, tag: nil)
        tag ||= method_name.name.tr('_', '-')

        define_method method_name do |**attributes, &block|
          Rails.logger.debug "Generate element #{tag} #{attributes.inspect}"
          ElementBuilder.of(self).build_element(tag, attributes, block)
        end

        registered_tags[method_name] = tag

        method_name
      end

      def register_void_tag(method_name, tag: nil)
        tag ||= method_name.name.tr('_', '-')

        define_method method_name do |**attributes|
          Rails.logger.debug "Generate void element #{tag} #{attributes.inspect}"
          ElementBuilder.of(self).build_void_element(tag, attributes)
        end

        registered_tags[method_name] = tag

        method_name
      end
    end
  end
end
