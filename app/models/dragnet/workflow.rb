module Dragnet
  # A resumable sequence of actions
  class Workflow < Action
    include Resumable

    attr_reader :name

    def self.tag
      string = name.demodulize
      string.downcase!
      string.to_sym
    end

    def initialize(actions, name: nil)
      raise 'only subclasses of Workflow can be instantiated' if self.class == Dragnet::Workflow

      @name = name || Utils.tagged_uuid(self.class.tag)
      @actions = actions
      @actions_by_name = actions.index_by(&:name)
    end

    def partial?
      actions.any?(&:partial?)
    end

    def invoke
      current_action.call(params)
    end

    private

    attr_accessor :current_action
    attr_reader :actions, :actions_by_name

    def initialize_parameters!(params)
      super

      self.current_action =
        if params.key?(:step)
          actions[params[:step]]
        elsif params.key?(:action)
          actions_by_name[params[:action]]
        else
          actions.first
        end

      self.params = params
    end
  end
end
