module Dragnet
  # A hash-like object that is used to store any state that is
  # necessary to resume the activity of a resumable object.
  class Continuation
    include Resumable

    attr_reader :id, :data

    delegate :[], :key?, to: :data

    def initialize(action_class_name, data)
      @id = Utils.short_uuid
      @action_class_name = action_class_name
      @data = data.to_h
      freeze
    end

    def resume_with(params)
      action_class.new.resume_with(params)
    end

    def action_class
      @action_class_name.constantize
    end
  end
end
