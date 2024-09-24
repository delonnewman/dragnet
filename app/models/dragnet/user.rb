# frozen_string_literal: true

module Dragnet
  class User < ApplicationRecord
    has_many :surveys, -> { where(retracted: false) }, class_name: 'Dragnet::Survey', dependent: :delete_all, foreign_key: :author_id, inverse_of: :author
    has_many :saved_reports, class_name: 'Dragnet::SavedReport', dependent: :delete_all, foreign_key: :author_id, inverse_of: :author
    has_many :data_grids, class_name: 'Dragnet::DataGrid', inverse_of: :user, dependent: :delete_all

    # To satisfy the Reportable protocol
    has_many :questions, through: :surveys
    has_many :records, through: :surveys
    has_many :events, through: :surveys

    has_many :visits, class_name: 'Ahoy::Visit', dependent: :nullify, inverse_of: :user

    devise :database_authenticatable, :registerable, :recoverable,
           :rememberable, :validatable, :trackable, :confirmable, :omniauthable

    with Workspace

    def gravatar_url
      hash = Digest::MD5.hexdigest(email)

      "https://www.gravatar.com/avatar/#{hash}"
    end

    def valid_email?
      email.present? && !email.end_with?('@example.com')
    end
  end
end
