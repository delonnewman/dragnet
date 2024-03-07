# frozen_string_literal: true

module Dragnet
  class Survey::SubmissionParametersProjection < Composed
    alias survey subject

    def project
      { answers_attributes: }
    end
    alias to_h project

    private

    def answers_attributes
      survey.questions.each_with_object({}) do |q, h|
        h[q.id] = %i[answer_id reply_id survey_id question_type_id value]
      end
    end
  end
end
