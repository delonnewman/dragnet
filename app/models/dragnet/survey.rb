# frozen_string_literal: true

module Dragnet
  class Survey < ApplicationRecord
    include SelfDescribable
    include UniquelyIdentifiable
    include Retractable
    include Presentable

    # Treat surveys as whole values
    scope :whole, -> { eager_load(:author, questions: %i[question_options]) }

    belongs_to :author, class_name: 'Dragnet::User'

    # Naming
    validates :name,
              presence: true,
              uniqueness: { scope: :author },
              on: :create
    before_validation { Name.assign!(self) }

    # Questions
    has_many :questions, -> { order(:display_order) },
             class_name: 'Dragnet::Question',
             dependent: :delete_all,
             inverse_of: :survey
    accepts_nested_attributes_for :questions, allow_destroy: true
    retract_associated :questions

    def types
      questions.map { it.type.class }
    end

    # Record Data
    has_many :answers,
             class_name: 'Dragnet::Answer',
             dependent: :delete_all,
             inverse_of: :survey

    has_many :replies,
             class_name: 'Dragnet::Reply',
             dependent: :delete_all,
             inverse_of: :survey
    retract_associated :replies

    # DataGrids
    has_many :data_grids,
             class_name: 'Dragnet::DataGrid',
             dependent: :delete_all,
             inverse_of: :survey

    def views
      Views.default.present(self)
    end

    # Survey specific mixins
    include Reporting
    include Submissions
    include Editing
    include Copying
    include Access
    include Recording
  end
end
