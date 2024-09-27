# frozen_string_literal: true

module Dragnet
  class Answer < ApplicationRecord
    include Retractable

    belongs_to :survey,   class_name: 'Dragnet::Survey'
    belongs_to :reply,    class_name: 'Dragnet::Reply'
    belongs_to :question, class_name: 'Dragnet::Question'
    accepts_nested_attributes_for :question

    scope :whole, -> { eager_load(:question_option, :question_type, question: %i[question_type question_options]) }

    # for Question Option values
    belongs_to :question_option, optional: true, class_name: 'Dragnet::QuestionOption'
    accepts_nested_attributes_for :question_option

    belongs_to :question_type, optional: true, class_name: 'Dragnet::QuestionType'
    accepts_nested_attributes_for :question_type
    delegate :type, to: :question_type
    before_save do
      self.question_type = question.question_type if question
    end

    before_save do
      type.before_saving_answer(self, question)
    end

    # Answers should be able to be treated as various kinds of values
    delegate :to_s, :blank?, to: :value, allow_nil: true
    delegate :to_i, :to_f, :to_r, to: :number_value, allow_nil: true

    def assign_value!(value)
      type.assign_value!(self, value)
    end
    alias value= assign_value!

    def value
      type.value(self)
    end

    def text_value
      value.to_s
    end

    def number_value
      type.number_value(self)
    end
  end
end
