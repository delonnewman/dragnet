class User < ApplicationRecord
  has_many :surveys, dependent: :delete_all
end
