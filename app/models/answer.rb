# frozen_string_literal: true

class Answer < ApplicationRecord
  include Retractable

  belongs_to :survey
  belongs_to :reply
  belongs_to :question

  # for question_option values
  belongs_to :question_option, optional: true

  delegate :to_s, :blank?, to: :value, allow_nil: true
  delegate :to_i, :to_f, to: :number_value, allow_nil: true

  belongs_to :question_type
  after_initialize do
    self.question_type = question.question_type if question
  end

  before_save do
    Dragnet::Perspectives::BeforeSavingAnswer.get(question_type).update(answer, question)
  end

  def assign_value!(value)
    evaluation.assign_value!(self, value)
  end
  alias value= assign_value!

  def value
    evaluation.value(self)
  end

  def text_value
    value.to_s
  end

  def number_value
    evaluation.number_value(self)
  end

  def assign_sort_value!
    answer.sort_value = sort_value
  end

  def sort_value
    evaluation.sort_value(self)
  end

  private

  def evaluation
    Dragnet::Perspectives::AnswerEvaluation.get(question_type)
  end
end
