class Question < ApplicationRecord
  include Settings

  validates :text, presence: true

  belongs_to :survey
  belongs_to :question_type
  delegate :renderer, to: :question_type

  has_many :question_options, dependent: :delete_all
  accepts_nested_attributes_for :question_options, allow_destroy: true

  has_many :followup_questions, dependent: :delete_all

  after_initialize do
    self.hash_code = Dragnet::Utils.hash_code(text) if text
  end
end
