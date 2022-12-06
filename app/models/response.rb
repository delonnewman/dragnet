class Response < ApplicationRecord
  belongs_to :form

  has_many :fields, through: :form

  has_many :items, class_name: 'ResponseItem'
  accepts_nested_attributes_for :items, reject_if: ->(attrs) { ResponseItem.new(attrs).blank? }

  advised_by Response::Submitting, delegating: %i[submit! submitted submitted!]

  # @!attribute answer_records
  #   @return [Array<ResponseItem>]
  serialize :response_item_cache

  before_save do
    self.response_item_cache = items.to_a
  end

  # @return [Array<ResponseItem>]
  def items_for(field)
    response_item_cache.to_a.select { |i| i.field_id == field.id }
  end
end
