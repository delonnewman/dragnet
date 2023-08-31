module Dragnet
  class QuestionOption < ApplicationRecord
    belongs_to :question, class_name: 'Dragnet::Question'

    validates :text, presence: true

    def to_s
      text
    end
  end
end
