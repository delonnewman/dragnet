# frozen_string_literal: true

module Dragnet
  class UniqueName
    def initialize(record, attribute: :name, scope: nil, root_name: "New #{record.class.model_name.human}")
      @record = record
      @attribute = attribute
      @root_name = root_name
      @scope_attribute = scope
    end

    def as_slug
      Utils.slug(as_name)
    end

    def as_name
      return record_name unless generate?

      generate
    end
    alias to_s as_name

    def generate
      n = auto_named_count
      n.zero? ? @root_name : "#{@root_name} (#{n})"
    end

    def generate?
      @record.name.blank? || auto_named? || duplicated_root? and @record.new_record? || scope_attribute_will_change?
    end

    private

    def scope_attribute_will_change?
      return false unless @scope_attribute

      @record.will_save_change_to_attribute?(@scope_attribute)
    end

    def auto_named?
      record_name.start_with?(@root_name)
    end

    def record_name
      @record.public_send(@attribute)
    end

    def duplicated_root?
      !unique_root?
    end

    def unique_root?
      auto_named_count.zero?
    end

    def auto_named_count
      model = @record.class
      field = model.arel_table[@attribute]
      query = model.where(@attribute => @root_name).or(model.where(field.matches("#{@root_name} (%)")))
      return query.count unless @scope_attribute

      query.where(@scope_attribute => record_scope_value).count
    end

    def record_scope_value
      @record.public_send(@scope_attribute)
    end
  end
end
