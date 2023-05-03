# frozen_string_literal: true

module Dragnet
  class Component < DOM::Element
    class << self
      def tag_name(klass = self)
        klass.name.split('::').last.underscore.sub("_component", '').to_sym
      end

      def component_name(tag_name)
        "#{(tag_name.is_a?(Symbol) ? tag_name.name : tag_name)}_component".classify
      end

      def find(tag_name)
        component_name(tag_name).safe_constantize
      end

      def find!(tag_name)
        component_name(tag_name).constantize
      end

      def inspect
        "#{self}(#{attributes.map { |(name, opt)| "#{name}:#{opt[:type]}" }.join(', ')})"
      end

      def attributes
        @attributes ||= {}
      end

      def attribute(name, type = :string, **options)
        attributes[name] = options.merge!(type: type)

        builder.define_singleton_method name do
          attributes[name]
        end

        define_method name do
          attributes[name]
        end

        name
      end

      attr_accessor :template_proc

      def template_proc?
        !!template_proc
      end

      def template(&block)
        return @html if defined?(@html)

        if template_proc?
          @html = builder.instance_exec(&template_proc)
        else
          raise ArgumentError, 'a block is required' unless block_given?
          self.template_proc = block
        end
      end

      def builder
        @builder ||= DOM::HTMLProxy.new(self)
      end

      def compiled_template
        @compiled_template ||= erubi.src
      end

      def template_string
        html_compiler.compile(self)
      end

      def html_compiler
        @@html_compiler ||= DOM::HTMLCompiler.new
      end

      private

      def erubi
        Erubi::Engine.new(template_string)
      end
    end

    delegate :template, :tag_name, :template_string, :compiled_template, to: :class

    def initialize(**attributes)
      self.class.attributes.each do |name, options|
        attributes[name] = options[:default] if attributes[name].blank? && options[:default]
        raise ArgumentError, "#{name} is required" if attributes[name].blank? && options[:required]
      end

      super(attributes: attributes, name: tag_name)
    end

    def compile
      self.class.html_compiler.compile(self)
    end
    alias to_s compile

    protected

    def tag
      @tag ||= HTMLProxy.new(self)
    end
  end
end
