# frozen_string_literal: true

module SelfDescribable
  extend ActiveSupport::Concern

  included do
    has_many :meta_data_records, class_name: 'MetaDatum', as: :self_describing
  end

  def meta_data
    @meta_data ||= meta_data_records.reduce({}) { |h, datum| h.merge!(datum.key => datum.value) }
  end

  def add_meta(key, value, type: value.class)
    meta_data_records.create!(key: key, value: String(value), key_type: type.name)
  end

  def remove_meta(key)
    meta_data_records.where(key: key).destroy
  end
end
