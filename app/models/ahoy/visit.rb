# frozen_string_literal: true

class Ahoy::Visit < ApplicationRecord
  self.table_name = 'ahoy_visits'

  has_many :events, class_name: 'Ahoy::Event', inverse_of: :visit, dependent: :delete_all

  belongs_to :user, optional: true
  has_one :reply, foreign_key: :ahoy_visit_id, inverse_of: :ahoy_visit, dependent: :nullify

  scope :of_visitor, ->(visitor_token) { where(ahoy_visits: { visitor_token: visitor_token }) }
end
