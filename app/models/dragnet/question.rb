# frozen_string_literal: true

module Dragnet
  class Question < ApplicationRecord
    include SelfDescribable
    include Retractable
    include Presentable

    validates :text, presence: true, uniqueness: { scope: :survey_id }

    belongs_to :survey, class_name: 'Dragnet::Survey'

    has_many :question_options, class_name: 'Dragnet::QuestionOption', dependent: :delete_all, inverse_of: :question
    accepts_nested_attributes_for :question_options, allow_destroy: true

    scope :whole, -> { eager_load(:question_options) }

    before_save do
      self.hash_code = Utils.hash_code(text) if text.present? && !hash_code
      self.form_name = Utils.slug(text, delimiter: '_') if text.present? && !form_name
    end

    def settings
      Settings.new(self)
    end
    memoize :settings

    def type
      type_class.new(self)
    end

    def type_class=(klass)
      self.type_class_name = klass.name
    end

    def type_class
      type_class_name.constantize
    end
  end
end
