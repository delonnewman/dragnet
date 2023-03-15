class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  delegate :to_s, to: :name
  delegate :answer_value_field, :filter_value, to: :type

  has_many :questions

  serialize :settings

  def setting_default(setting)
    settings.dig(setting, :default)
  end

  def type_class
    type_class_name.safe_constantize
  end

  def type
    type_class.new(self)
  end
  memoize :type

  def renderer(perspective = ApplicationPerspective.new(nil))
    AnswerRenderer.new(self, perspective)
  end
  memoize :renderer
end
