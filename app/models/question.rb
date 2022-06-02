class Question < ApplicationRecord
  belongs_to :survey
  belongs_to :question_type

  has_many :question_options, dependent: :delete_all
  accepts_nested_attributes_for :question_options

  has_many :followup_questions, dependent: :delete_all

  after_initialize do
    self.hash_code = text.hash
    self.display_order = 0 unless display_order
  end
end
