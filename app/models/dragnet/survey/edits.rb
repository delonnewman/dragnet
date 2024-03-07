module Dragnet
  module Survey::Edits
    def self.current(survey)
      latest(survey) || new(survey)
    end

    def self.latest(survey)
      survey.edits.where(applied: false).order(created_at: :desc).first
    end

    def self.new(survey, data: survey.projection)
      SurveyEdit.new(survey:, survey_data: data)
    end

    def self.create!(survey)
      new(survey).save!
    end

    def self.present?(survey)
      latest(survey).present?
    end
  end
end
