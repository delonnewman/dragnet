# frozen_string_literal: true

class User < ApplicationRecord
  has_many :surveys, dependent: :delete_all, foreign_key: :author_id, inverse_of: :author
  has_many :saved_reports, dependent: :delete_all, foreign_key: :author_id, inverse_of: :author

  # To Satisfy the Reportable Interface
  has_many :questions, through: :surveys
  has_many :replies, through: :surveys

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable, :confirmable, :omniauthable
end
