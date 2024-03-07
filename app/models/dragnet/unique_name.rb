# frozen_string_literal: true

module Dragnet
  class UniqueName
    def initialize(record, attribute: :name, scope: nil, root_name: "New #{record.class.model_name.human}")
      @record = record
      @attribute = attribute
      @root_name = root_name
      @scope = scope
    end

    def to_s
      name = record_name
      return name if name.present?

      unique_name
    end

    def record_name
      record.public_send(attribute)
    end

    def record_scope_value
      record.public_send(scope)
    end

    def unique_name
      n = auto_named_count
      n.zero? ? root_name : "#{root_name} (#{n})"
    end

    def generate_name?
      name.blank? || auto_named? || duplicated_root? and new_record? || scope_attribute_will_change?
    end

    def scope_attribute_will_change?
      return true unless scope

      will_save_change_to_attribute?(scope)
    end

    def auto_named?
      name.start_with?(root_name)
    end

    def duplicated_root?
      !unique_root?
    end

    def unique_root?
      auto_named_count.zero?
    end

    def auto_named_count
      query = model.where(attribute => root_name).or(model.where(attribute => "#{root_name} (%)"))
      return query.count unless scope

      query.or(model.where(scope => record_scope_value)).count
    end

    private

    def model
      record.class
    end

    attr_reader :record, :attribute, :root_name, :scope

    delegate :name, :slug, :new_record?, :will_save_change_to_attribute?, to: :@record
  end
end
