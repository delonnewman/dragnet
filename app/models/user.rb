# frozen_string_literal: true

class User < ApplicationRecord
  has_many :surveys, -> { where(retracted: false) }, dependent: :delete_all, foreign_key: :author_id, inverse_of: :author
  has_many :saved_reports, dependent: :delete_all, foreign_key: :author_id, inverse_of: :author
  has_many :data_grids, inverse_of: :user, dependent: :delete_all

  # To satisfy the Reportable protocol
  has_many :questions, through: :surveys
  has_many :records, through: :surveys
  has_many :events, through: :surveys

  has_many :visits, class_name: 'Ahoy::Visit', dependent: :nullify, inverse_of: :user
  # has_many :events, class_name: 'Ahoy::Event', dependent: :nullify, inverse_of: :user

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :trackable, :confirmable, :omniauthable

  with ReplySubmissionPolicy, delegating: %i[can_preview_survey? can_update_reply? can_edit_reply? can_create_reply?]
  with Workspace

  def gravatar_url
    hash = Digest::MD5.hexdigest(email)

    "https://www.gravatar.com/avatar/#{hash}"
  end

  def valid_email?
    email.present? && !email.end_with?('@example.com')
  end
end
