class Dragnet::Survey
  module Editing
    extend ActiveSupport::Concern

    included do
      attribute :editing_status, EditingStatus
      before_validation { EditingStatus.assign_default!(self) }

      has_many :edits, -> { extending EditsExtension },
               class_name: 'Dragnet::SurveyEdit',
               dependent: :delete_all,
               inverse_of: :survey
    end

    def edited?
      edits.not_applied.latest.present?
    end

    def edited
      Dragnet::EditedSurvey.build(self)
    end

    def projection
      DataProjection.new(self).to_h
    end
  end
end
