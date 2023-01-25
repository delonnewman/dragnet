module Dragnet
  class Advice
    include Dragnet

    class << self
      def advised_object_method_name(advised_class)
        return unless advised_class

        advised_class.name.split('::').last.underscore.to_sym
      end

      def after(name, &block)
        advise_method(name, :after, &block)
      end

      def before(name, &block)
        advise_method(name, :before, &block)
      end

      def advise_method(name, phase, &block)
        raise 'can only advise methods on classes' unless advised_class.is_a?(Class)

        aliased = :"#{name}_without_advice"
        advised_class.alias_method(aliased, name)

        case phase
        when :before
          advised_class.define_method(name) do |*args, **kwargs|
            advised_object.instance_exec(*args, **kwargs, &block)
            send(aliased, *args, **kwargs)
          end
        when :after
          advised_class.define_method(name) do |*args, **kwargs|
            result = send(aliased, *args, **kwargs)
            advised_object.instance_exec(result, &block)
          end
        else
          raise "invalid phase #{phase.inspect}"
        end
      end

      def advises(advised_class, as: advised_object_method_name(advised_class), args: EMPTY_ARRAY)
        self.advised_class = advised_class
        self.advised_object_alias = as
        self.advised_args = args

        args.each do |arg|
          attr_reader(arg)
        end

        define_method(as) { advised_object } if as
      end

      attr_reader :advised_class, :advised_object_alias, :advised_args

      private

      attr_writer :advised_class, :advised_object_alias, :advised_args
    end

    attr_reader :advised_object

    delegate :advised_class, :advised_args, to: :class

    def initialize(advised_object, *args)
      if advised_class.is_a?(Class) && !advised_object.is_a?(advised_class)
        raise "can't advise #{advised_object.inspect}:#{advised_object.class}"
      end

      unless args.count == advised_args.count
        raise ArgumentError, "wrong number of arguments (given #{args.count + 1} expected #{advised_args.count + 1}"
      end

      @advised_object = advised_object

      advised_args.each_with_index do |arg_name, i|
        instance_variable_set(:"@#{arg_name}", args[i])
      end
    end
  end
end
