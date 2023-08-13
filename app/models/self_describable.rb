# frozen_string_literal: true

module SelfDescribable
  extend ActiveSupport::Concern

  included do
    has_many :meta_data_records, class_name: 'MetaDatum', as: :self_describable
    with Parsing
  end

  # @param [String, Symbol] key
  # @param alt
  def get_meta(key, alt = nil)
    records = meta_data_records.where(key: key)
    return alt if records.empty?

    parsing.parse_meta(records)
  end
  alias get_setting get_meta

  # @return [Hash{Symbol => Object}]
  def meta_data
    return @meta_data if @meta_data

    grouped = meta_data_records.group_by { _1.key.to_sym }
    @meta_data = grouped.transform_values! { parsing.parse_meta(_1, grouped) }
  end
  alias settings meta_data

  def meta_data?
    !meta_data_records.empty?
  end

  # @param [String, Symbol] key
  # @param value
  #
  # @return [Array<MetaDatum>]
  def create_meta_datum!(key, value)
    meta_data_records.create!(Evaluation.meta_attributes(key, value))
  end

  # @param [String, Symbol] key
  # @param value
  #
  # @return [MetaDatum]
  def build_meta_datum(key, value)
    meta_data_records.build(Evaluation.meta_attributes(key, value))
  end

  # @param [String, Symbol] key
  #
  # @return [MetaDatum]
  def destroy_meta_datum(key)
    meta_data_records.where(key: key).destroy
  end

  # @param [Hash] data_hash
  #
  # @return [void]
  def meta_data=(data_hash)
    self.meta_data_records = data_hash.flat_map do |key, value|
      Evaluation.meta_attributes(key, value).map do |attributes|
        MetaDatum.new(attributes)
      end
    end
  end
  alias settings= meta_data=
end
