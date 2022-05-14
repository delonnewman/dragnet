class Reply < ApplicationRecord
  belongs_to :survey

  has_many :answers
  has_many :questions, through: :survey
end
