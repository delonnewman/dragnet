class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers
  accepts_nested_attributes_for :answers
end
