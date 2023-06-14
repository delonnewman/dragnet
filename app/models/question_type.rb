# frozen_string_literal: true

class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  has_many :questions, dependent: :restrict_with_error, inverse_of: :question_type

  delegate :to_s, to: :name

  # TODO: move these to meta data
  serialize :settings
  serialize :answer_value_fields # TODO: remove, make the field usage explicit in perspectives

  def self.get(ident)
    QuestionType.find_by(slug: ident)
  end
  memoize self: :get

  def setting_default(setting)
    settings&.dig(setting, :default)
  end
end
