class Report
  attr_reader :field_ids, :name

  def initialize(attributes)
    @field_ids, @name = attributes.values_at(:field_ids, :name)
  end

  def fields
    @fields ||= Field.where(id: field_ids).select(:id, :text).to_a
  end

  def items
    ResponseItem.includes(field: [:field_type]).where(field_id: field_ids)
  end

  def responses
    Response
      .includes(:items)
      .joins(:items)
      .where('responses.submitted and reponse_items.field_id in (?)', field_ids)
      .order('responses.created_at DESC')
  end
end
