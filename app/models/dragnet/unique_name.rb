# frozen_string_literal: true

module Dragnet
  class UniqueName
    def initialize(record: nil, scope: nil, record_class: nil, root_name: nil, name: '')
      @record          = record
      @scope_attribute = scope
      @record_class    = record_class || record.class
      @root_name       = root_name || "New #{@record_class.model_name.human}"
      @name            = name || record.name
    end

    def as_slug
      return @record.slug if @record && @record.slug.present? && !generate?

      Utils.slug(as_name)
    end

    def as_name
      return @name unless generate?

      generate
    end
    alias to_s as_name

    def generate
      n = auto_named_count
      n.zero? ? @root_name : "#{@root_name} (#{n})"
    end

    def generate?
      !record_name? || auto_named? || duplicated_root? and
        @record.nil? || record_new? || scope_attribute_will_change?
    end

    private

    def record_name?
      @record && @record.name.present?
    end

    def record_new?
      @record && @record.new_record?
    end
    
    def scope_attribute_will_change?
      return false unless @record && @scope_attribute

      @record.will_save_change_to_attribute?(@scope_attribute)
    end

    def auto_named?
      @name.start_with?(@root_name)
    end

    def duplicated_root?
      !unique_root?
    end

    def unique_root?
      auto_named_count.zero?
    end

    def auto_named_count
      field = @record_class.arel_table[:name]
      query = @record_class.where(name: @root_name).or(@record_class.where(field.matches("#{@root_name} (%)")))
      return query.count unless @record && @scope_attribute

      query.where(@scope_attribute => record_scope_value).count
    end

    def record_scope_value
      @record.public_send(@scope_attribute)
    end
  end
end
