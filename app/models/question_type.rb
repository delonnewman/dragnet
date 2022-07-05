class QuestionType < ApplicationRecord
  include Slugged

  has_many :questions

  serialize :settings

  def countable?
    settings.fetch(:countable, false)
  end
end
