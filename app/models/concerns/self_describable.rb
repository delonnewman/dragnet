# frozen_string_literal: true

module SelfDescribable
  extend ActiveSupport::Concern

  included do
    has_many :meta_data_records, class_name: 'MetaDatum', as: :self_describable
  end

  def get_meta(key, alt = nil)
    records = meta_data_records.where(key: key)
    return alt if records.empty?

    parse_meta(records)
  end

  def remove_meta(key)
    meta_data_records.where(key: key).destroy
  end

  def meta_data
    return @meta_data if @meta_data

    grouped = meta_data_records.group_by { _1.key.to_sym }
    @meta_data = grouped.transform_values! { parse_meta(_1, grouped) }
  end

  def parse_meta(records, grouped = nil)
    if records.count == 1
      parse_single_meta(records.first)
    elsif records.first.key_type != 'ref'
      parse_multi_meta(records)
    else
      parse_ref_meta(records, grouped)
    end
  end

  def add_meta(key, value)
    meta_data_records.create!(meta_attributes(key, value))
  end

  def meta_attributes(key, value)
    case value
    when Array
      multi_meta_attributes(key, value)
    when Hash
      ref_meta_attributes(key, value)
    else
      single_meta_attributes(key, value)
    end
  end

  private

  def parse_ref_meta(records, grouped)
    records.reduce({}) do |h, record|
      key = record.value.to_sym
      records = grouped ? grouped[key] : meta_data_records.where(key: key)
      h.merge(key => parse_meta(records, grouped))
    end
  end

  def parse_multi_meta(records)
    records.map do |record|
      parse_single_meta(record)
    end
  end

  def parse_single_meta(datum)
    Kernel.public_send(datum.key_type, datum.value)
  end

  def multi_meta_attributes(key, values)
    values.map do |value|
      single_meta_attributes(key, value)
    end
  end

  def ref_meta_attributes(key, deref)
    deref.reduce([]) do |a, (k, v)|
      a << single_meta_attributes(key, k, type: :ref)
      if v.is_a?(Hash)
        ref_meta_attributes(k, v).each do |attr|
          a << attr
        end
        a
      else
        a << single_meta_attributes(k, v)
      end
    end
  end

  def single_meta_attributes(key, value, type: value.class)
    { key: key, value: String(value), key_type: type.name }
  end
end
