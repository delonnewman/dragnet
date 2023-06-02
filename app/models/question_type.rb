class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  has_many :questions

  delegate :to_s, to: :name

  serialize :settings

  def self.get(ident)
    QuestionType.find_by(slug: ident)
  end
  memoize self: :get

  def setting_default(setting)
    settings&.dig(setting, :default)
  end
end
