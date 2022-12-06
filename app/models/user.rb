class User < ApplicationRecord
  has_many :forms, dependent: :delete_all
end
