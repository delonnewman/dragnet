module Dragnet
  class EditedSurvey
    include ActiveModel::API
    include ActiveModel::Attributes
    include Memoizable

    attribute :id
    attribute :name
    attribute :description
    attribute :author_id
    attribute :editing_status, Survey::EditingStatus
    attribute :questions_attributes

    def self.build(survey, edits: survey.edits.not_applied.order(created_at: :asc))
      new(edits.merged_attributes)
    end

    def find_question(question_id)
      questions.find { |q| q.id == question_id } or
        raise ActiveRecord::RecordNotFound
    end
    
    def questions
      questions_attributes.map do |attributes|
        EditedQuestion.new(attributes)
      end.sort_by(&:display_order)
    end
    memoize :questions

    def persisted?
      true
    end

    def readonly?
      true
    end
  end
end
