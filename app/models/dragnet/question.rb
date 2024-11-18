# frozen_string_literal: true

module Dragnet
  class Question < ApplicationRecord
    include SelfDescribable
    include Retractable

    validates :text, presence: true, uniqueness: { scope: :survey_id }

    belongs_to :survey, class_name: 'Dragnet::Survey'

    belongs_to :question_type, class_name: 'Dragnet::QuestionType'
    accepts_nested_attributes_for :question_type
    delegate :type, to: :question_type

    has_many :question_options, class_name: 'Dragnet::QuestionOption', dependent: :delete_all, inverse_of: :question
    accepts_nested_attributes_for :question_options, allow_destroy: true

    scope :whole, -> { eager_load(:question_type, :question_options) }

    before_save do
      self.hash_code = Utils.hash_code(text) if text.present? && !hash_code
      self.form_name = Utils.slug(text, delimiter: '_') if text.present? && !form_name
    end

    def question_type_ident=(ident)
      self.question_type = QuestionType.get(ident)
    end

    # TODO: not sure why this isn't being created by `accepts_nested_attributes_for`
    def question_type_attributes=(attributes)
      self.question_type = QuestionType.new(attributes)
    end

    def settings
      Settings.new(self)
    end
    memoize :settings

    def type
      question_type
    end
  end
end
