module Dragnet
  # A resumable sequence of actions
  class Workflow
    include Resumable

    attr_reader :name

    def self.tag
      string = name.demodulize
      string.downcase!
      string.to_sym
    end

    def initialize(actions, name: nil)
      @name = name || Utils.tagged_uuid(self.class.tag)
      @actions = actions
      @actions_by_name = actions.index_by(&:name)
    end

    def invoke(params)
      @actions.first.invoke(params)
    end

    def resume_with(continuation)
      action =
        if continuation.key?(:action_index)
          @actions[continuation[:action_index]]
        elsif continuation.key?(:action_name)
          @actions_by_name[continuation[:action_name]]
        end
      raise 'Can not resume workflow without action' unless action

      action.resume_with(continuation.params)
    end
  end
end
