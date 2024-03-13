# frozen_string_literal: true

module Dragnet
  class Question < ApplicationRecord
    include SelfDescribable
    include Retractable

    validates :text, presence: true

    with Settings, delegating: %i[setting? setting]

    belongs_to :survey, class_name: 'Dragnet::Survey'
    belongs_to :question_type, class_name: 'Dragnet::QuestionType'
    delegate :type, to: :question_type

    has_many :question_options, class_name: 'Dragnet::QuestionOption', dependent: :delete_all, inverse_of: :question
    accepts_nested_attributes_for :question_options, allow_destroy: true

    before_save do
      self.hash_code = Utils.hash_code(text) if text.present? && !hash_code
    end

    def question_type_ident=(ident)
      self.question_type = QuestionType.get(ident)
    end
  end
end
