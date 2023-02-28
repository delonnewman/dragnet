class QuestionType < ApplicationRecord
  include Naming
  include SelfDescribable

  delegate :to_s, to: :name

  has_many :questions

  serialize :settings

  def setting_default(setting)
    settings.dig(setting, :default)
  end

  def type_class
    type_class_name.safe_constantize
  end
end
