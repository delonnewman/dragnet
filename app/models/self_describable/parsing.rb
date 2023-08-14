# frozen_string_literal: true

module SelfDescribable
  class Parsing < Dragnet::Advice
    advises SelfDescribable

    def parse_meta(records, grouped = nil)
      return if records.nil? || records.empty?

      if records.count == 1
        parse_single_meta(records.first)
      elsif records.first.key_type != 'ref'
        parse_multi_meta(records)
      else
        parse_ref_meta(records, grouped)
      end
    end

    def parse_ref_meta(records, grouped)
      records.each_with_object({}) do |record, h|
        key     = record.value.to_sym
        records = grouped ? grouped[key] : self_describable.meta_data_records.where(key: key)
        h[key]  = parse_meta(records, grouped)
        grouped&.delete(key) # remove referenced keys from grouping
      end
    end

    def parse_multi_meta(records)
      records.map do |record|
        parse_single_meta(record)
      end
    end

    class Error < RuntimeError; end

    def parse_single_meta(datum)
      case datum.key_type
      when 'String'
        datum.value
      when 'Symbol'
        datum.value.to_sym
      when 'TrueClass'
        true
      when 'FalseClass'
        false
      when 'Integer', 'Float', 'Rational'
        Kernel.public_send(datum.key_type, datum.value)
      when 'Date'
        Date.parse(datum.value)
      when 'Time'
        Time.zone.parse(datum.value)
      else
        raise Error, "unable to parse values of type #{datum.key_type}"
      end
    end
  end
end
