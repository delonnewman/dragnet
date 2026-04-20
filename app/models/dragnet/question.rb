# frozen_string_literal: true

module Dragnet
  class Question < ApplicationRecord
    include SelfDescribable
    include Retractable
    include Presentable
    include Typeable

    validates :text, presence: true, uniqueness: { scope: :survey_id }

    belongs_to :survey, class_name: 'Dragnet::Survey'

    has_many :question_options, class_name: 'Dragnet::QuestionOption', dependent: :delete_all, inverse_of: :question
    accepts_nested_attributes_for :question_options, allow_destroy: true

    scope :whole, -> { eager_load(:question_options) }

    before_save do
      self.hash_code = Utils.hash_code(text) if text.present? && !hash_code
      self.form_name = Utils.slug(text, delimiter: '_') if text.present?
    end

    before_validation do
      self.text = UniqueName.new(record: self, scope: :survey_id, attribute_name: :text).to_s
      self.type_class = Dragnet::Types::Text unless type_class_name
    end

    def settings
      Settings.new(self)
    end
    memoize :settings

    def removed?
      false
    end
  end
end
