# frozen_string_literal: true

module Dragnet
  # Provides data access and business rules for survey data grids
  class DataGrid < ApplicationRecord
    validates :survey_id, uniqueness: { scope: :user_id }
    validates :user_id, uniqueness: { scope: :survey_id }

    # Surveys & Questions
    belongs_to :survey, class_name: 'Dragnet::Survey', inverse_of: :data_grids
    has_many :questions, through: :survey, inverse_of: :survey
    has_many :replies, through: :survey, inverse_of: :survey

    belongs_to :user, class_name: 'Dragnet::User', inverse_of: :data_grids

    # RecordChanges
    has_many :record_changes, class_name: 'Dragnet::RecordChange', through: :survey, inverse_of: :survey
    delegate :record_changes?, to: :survey

    scope :whole, -> { eager_load(survey: %i[author], questions: %i[question_type question_options]) }

    def self.find_or_create!(survey, user: survey.author)
      grid = find_by(user_id: user.id, survey_id: survey.id)
      return grid if grid

      create!(user:, survey:)
    end

    def query(params)
      Query.new(questions, params, defaults)
    end
    memoize :query

    def default_sort_direction
      defaults.fetch(:sort_direction, :desc)
    end

    # TODO: make this configurable, probably should be meta data
    def defaults
      {
        sort_direction: :desc,
        sort_by:        :created_at,
        filter_by:      EMPTY_HASH,
      }
    end
  end
end
