# frozen_string_literal: true

module Dragnet
  class Answer < ApplicationRecord
    include Retractable

    belongs_to :survey,   class_name: 'Dragnet::Survey'
    belongs_to :reply,    class_name: 'Dragnet::Reply'

    belongs_to :question, class_name: 'Dragnet::Question'
    accepts_nested_attributes_for :question
    delegate :type, to: :question

    scope :whole, -> { eager_load(:question_option, question: %i[question_options]) }

    # for Question Option values
    belongs_to :question_option, optional: true, class_name: 'Dragnet::QuestionOption'
    accepts_nested_attributes_for :question_option

    before_save do
      type&.send_action(:do_before_saving_answer, answer: self, question:)
    end

    # Answers should be able to be treated as various kinds of values
    delegate :to_s, :blank?, to: :value, allow_nil: true
    delegate :to_i, :to_f, :to_r, to: :number_value, allow_nil: true

    def text_value
      value.to_s
    end

    def value
      type&.send_action(:get_value, answer: self)
    end

    def value=(value)
      type&.send_action(:assign_value, answer: self, value:)
    end

    def number_value
      type&.send_action(:get_number_value, answer: self)
    end
  end
end
