# frozen_string_literal: true

module Dragnet
  class Survey::SubmissionParametersProjection < Composed
    alias survey subject

    def project
      [:id, :survey_id, { answers_attributes: }]
    end

    private

    def answers_attributes
      survey.questions.each_with_object({}) do |q, h|
        h[q.id] = %i[question_id reply_id survey_id question_type_id value]
      end
    end
  end
end
