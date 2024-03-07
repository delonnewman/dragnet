# frozen_string_literal: true

module Dragnet
  # Provides data access and business rules for survey data grids
  class DataGrid < ApplicationRecord
    # Surveys & Questions
    belongs_to :survey, class_name: 'Dragnet::Survey', inverse_of: :data_grids
    has_many :questions, through: :survey, inverse_of: :survey
    has_many :replies, through: :survey, inverse_of: :survey

    belongs_to :user, class_name: 'Dragnet::User', inverse_of: :data_grids

    # RecordChanges
    has_many :record_changes, class_name: 'Dragnet::RecordChange', through: :survey, inverse_of: :survey
    delegate :record_changes?, to: :survey

    def self.ensure!(survey, user)
      survey.data_grids.find_by(user_id: user.id) || survey.data_grids.create!(user:)
    end

    def self.ensure(survey, user)
      survey.data_grids.find_by(user_id: user.id) || survey.data_grids.create(user:)
    end

    def query(params)
      Query.new(survey, params)
    end
    memoize :query

    # @param [Hash] params
    #
    # @return [ActiveRecord::Relation<Reply>]
    def records(**params)
      query(params).records
    end

    def present(*args, **kwargs)
      DataGridPresenter.new(self, *args, **kwargs)
    end
  end
end
