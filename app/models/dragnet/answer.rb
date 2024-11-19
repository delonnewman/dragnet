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

    belongs_to :question_type, optional: true, class_name: 'Dragnet::QuestionType' # Why does this need to be optional?
    accepts_nested_attributes_for :question_type
    delegate :type, to: :question_type, allow_nil: true
    before_save do
      self.question_type = question.question_type if question
    end

    before_save do
      type&.perform(:do_before_saving_answer, answer: self, question:)
    end

    # Answers should be able to be treated as various kinds of values
    delegate :to_s, :blank?, to: :value, allow_nil: true
    delegate :to_i, :to_f, :to_r, to: :number_value, allow_nil: true

    def text_value
      value.to_s
    end

    def value
      type&.perform(:get_value, answer: self)
      type&.perform(type&.get_value(answer: self))
    end

    def value=(value)
      type&.perform(:assign_value, answer: self, value:)
    end

    def number_value
      type&.perform(:get_number_value, answer: self)
    end
  end
end
