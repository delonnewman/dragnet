class User < ApplicationRecord
  has_many :surveys, dependent: :delete_all, foreign_key: :author_id

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable, :confirmable, :omniauthable
end
