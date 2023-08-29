# frozen_string_literal: true

class Question < ApplicationRecord
  include SelfDescribable
  include Retractable

  validates :text, presence: true

  with Settings, delegating: %i[setting? setting]

  belongs_to :survey
  belongs_to :question_type

  has_many :question_options, dependent: :delete_all, inverse_of: :question
  accepts_nested_attributes_for :question_options, allow_destroy: true

  # TODO: Remove followup questions
  has_many :followup_questions, dependent: :delete_all

  after_initialize do
    self.hash_code = Dragnet::Utils.hash_code(text) if text
  end

  def question_type_ident=(ident)
    self.question_type = QuestionType.get(ident)
  end
end
