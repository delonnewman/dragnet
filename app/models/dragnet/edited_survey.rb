module Dragnet
  class EditedSurvey
    include ActiveModel::API
    include ActiveModel::Attributes
    include ActiveModel::Conversion

    attribute :id
    attribute :name
    attribute :description
    attribute :author_id
    attribute :editing_status, Survey::EditingStatus
    attribute :questions_attributes

    def questions
      questions_attributes.map do |attributes|
        Question.new(attributes.merge(survey_id: id))
      end
    end

    def persisted?
      true
    end
  end
end
