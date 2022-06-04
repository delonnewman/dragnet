class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers
  accepts_nested_attributes_for :answers

  def answers_to(question)
    if new_record?
      answers.select { |a| a.question == question }
    else
      answers.where(question: question)
    end
  end
end
