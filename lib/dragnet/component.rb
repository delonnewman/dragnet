# frozen_string_literal: true

module Dragnet
  class Component < DOM::HTMLElement
    class << self
      def tag_name(klass = self)
        (klass.name || superclass.name).split('::').last.underscore.sub("_component", '').to_sym
      end

      def component_name(tag = tag_name)
        "#{(tag_name.is_a?(Symbol) ? tag.name : tag)}_component".classify
      end

      def find(tag_name)
        component_name(tag_name).safe_constantize
      end

      def find!(tag_name)
        component_name(tag_name).constantize
      end

      def exists?(tag_name)
        find(tag_name).present?
      end
      alias exist? exists?

      def inspect
        "#{component_name}(#{attributes.map { |(name, opt)| "#{name}:#{opt[:type]}" }.join(', ')})"
      end

      def bind(attributes)
        klass = Class.new(self)
        klass.class_eval do
          attributes.each do |name, value|
            bind_value(name, value)
          end
        end
        klass.template_proc = template_proc
        klass
      end

      def binding_name(name)
        :"@#{name}"
      end

      def bindings
        @bindings ||= {}
      end

      def bound?(name)
        bindings.include?(name)
      end

      def bind_value(name, value)
        bindings[name] = value
      end

      def bound_value!(name)
        bindings.fetch(name) do
          raise "`#{name}` is not bound in #{self}"
        end
      end

      def bound_value(name)
        bindings[name]
      end

      def definitions
        @definitions ||= []
      end

      def define(name, &block)
        definitions << name

        template_context.define_singleton_method(name, &block)

        define_method name do
          if self.class.bound?(name)
            self.class.bound_value!(name)
          else
            instance_eval(&block)
          end
        end

        name
      end
      alias let define

      def attributes
        attrs = @attributes || {}

        if superclass.respond_to?(:attributes)
          superclass.attributes.merge(attrs)
        else
          attrs
        end
      end

      def attribute(name, type = :object, **options)
        @attributes ||= {}
        @attributes[name] = options.merge!(type: type)

        define name do
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
          @html = template_context.instance_exec(&template_proc)
        else
          raise ArgumentError, 'a block is required' unless block_given?
          self.template_proc = block
        end
      end

      def template_context
        @template_context ||= DOM::TemplateContext.new(self)
      end

      def compiled_template
        @compiled_template ||= erubi.src
      end

      def compile
        html_compiler.compile(self)
      end

      private

      def erubi
        Erubi::Engine.new(compile)
      end
    end

    delegate :template, :tag_name, :template_string, :compiled_template, to: :class

    def initialize(**attributes)
      self.class.attributes.each do |name, options|
        attributes[name] = self.class.bound_value(name) if attributes[name].blank? && self.class.bound?(name)
        attributes[name] = options[:default] if attributes[name].blank? && options[:default]
        if attributes[name].blank? && options[:required]
          raise ArgumentError, "#{name} is required for #{self.class}"
        end
      end

      super(attributes: attributes, name: tag_name)
    end

    protected

    def tag
      @tag ||= DOM::HTMLProxy.new(self)
    end
  end
end
