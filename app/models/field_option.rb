class FieldOption < ApplicationRecord
  belongs_to :field

  validates :text, presence: true

  has_many :dependent_fields, class_name: 'Field'
  accepts_nested_attributes_for :dependent_fields

  def to_s
    text
  end
end
