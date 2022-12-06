class FieldType < ApplicationRecord
  include Slugged

  has_many :fields

  serialize :settings

  def countable?
    settings.fetch(:countable, false)
  end
end
