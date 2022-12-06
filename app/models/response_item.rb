class ResponseItem < ApplicationRecord
  belongs_to :form
  belongs_to :response
  belongs_to :field

  # for question_option values
  belongs_to :field_option, optional: true
  belongs_to :field_type

  before_validation do
    self.field_type = field.field_type if field
  end

  def to_s
    value.to_s
  end

  def blank?
    value.blank?
  end

  def value=(value)
    case field_type.ident
    when :text
      if field_type.long_answer?
        self.long_text_value = value
      else
        self.short_text_value = value
      end
    when :multiple_choice, :checkboxes
      self.field_option = value
    end
  end

  def text_value
    case field_type.ident
    when :text
      field_type.long_answer? ? long_text_value : short_text_value
    when :multiple_choice, :checkboxes
      field_option&.text
    end
  end
  alias value text_value

  def number_value
    case field_type.ident
    when :multiple_choice, :checkboxes
      field_option&.weight
    end
  end
end
