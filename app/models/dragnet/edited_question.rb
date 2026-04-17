module Dragnet
  class EditedQuestion
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :id
    attribute :text
    attribute :type_class_name
    attribute :required, :boolean
    attribute :display_order, :integer
    attribute :question_options_attributes
    attribute :_destroy, :boolean
    attribute :_update, :boolean

    def required?
      required
    end

    def removed?
      _destroy
    end

    def updated?
      _update
    end

    def persisted?
      true
    end

    def new_question?
      int_id = id.to_i
      int_id.to_s == id && int_id < 0
    end

    def readonly?
      true
    end

    def type
      type_class.new(self)
    end

    def type_class
      type_class_name.constantize
    end
  end
end
