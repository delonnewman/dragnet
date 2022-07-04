class QuestionType < ApplicationRecord
  include Slugged

  has_many :questions

  serialize :settings
end
