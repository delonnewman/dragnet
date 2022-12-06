class Field < ApplicationRecord
  validates :text, presence: true

  belongs_to :form
  belongs_to :field_type

  has_many :field_options, dependent: :delete_all
  accepts_nested_attributes_for :field_options, allow_destroy: true

  has_many :dependent_fields, dependent: :delete_all

  serialize :settings

  before_save do
    self.hash_code = Dragnet::Utils.hash_code(text) if text
  end

  def countable?
    field_type.countable?
  end
end
