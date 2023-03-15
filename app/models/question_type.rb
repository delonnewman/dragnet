class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  has_many :questions

  delegate :to_s, to: :name

  serialize :settings

  def setting_default(setting)
    settings&.dig(setting, :default)
  end

  def renderer(perspective = ApplicationPerspective.new(nil))
    AnswerRenderer.new(self, perspective)
  end
  memoize :renderer
end
