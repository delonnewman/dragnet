module Dragnet
  class EditedQuestion
    include ActiveModel::API
    include ActiveModel::Attributes

    attribute :id
    attribute :text
    attribute :type_class_name
    attribute :required
    attribute :display_order
    attribute :question_options_attributes
    attribute :_destroy
    attribute :_update

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
