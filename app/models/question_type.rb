class QuestionType < ApplicationRecord
  include Slugged

  has_many :questions

  serialize :settings

  def setting_default(setting)
    settings.dig(setting, :default)
  end
end
