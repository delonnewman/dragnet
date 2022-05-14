class Survey < ApplicationRecord
  belongs_to :user

  has_many :questions, dependent: :destroy

  has_many :replies
  has_many :answers
end
