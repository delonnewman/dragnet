# frozen_string_literal: true

class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  has_many :questions, dependent: :restrict_with_error, inverse_of: :question_type

  delegate :to_s, to: :name

  def self.get(ident)
    QuestionType.find_by(slug: ident)
  end
  memoize self: :get

  def setting_default(setting)
    settings&.dig(setting, :default)
  end
end
