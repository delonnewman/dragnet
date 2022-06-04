class Question < ApplicationRecord
  belongs_to :survey
  belongs_to :question_type

  has_many :question_options, dependent: :delete_all
  accepts_nested_attributes_for :question_options

  has_many :followup_questions, dependent: :delete_all

  before_save do
    self.hash_code = Dragnet::Utils.hash_code(text) if text
  end
end
