class QuestionType < ApplicationRecord
  include Slugged

  delegate :to_s, to: :name

  has_many :questions

  serialize :settings

  def setting_default(setting)
    settings.dig(setting, :default)
  end
end
