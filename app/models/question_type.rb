class QuestionType < ApplicationRecord
  include Slugged

  has_many :questions
end
