# frozen_string_literal: true

module Dragnet
  class Survey::SubmissionParameters < Composed
    alias survey subject

    def submission_attributes
      survey.questions.map(&:form_name)
    end

    def submission_data(reply, params)
      data = params.to_h
      questions = survey.questions.where(form_name: data.keys)

      {
        answers_attributes: questions.map do |question|
          {
            question_id: question.id,
            question_type_id: question.question_type_id,
            reply_id: reply.id,
            survey_id: survey.id,
            value: data[question.form_name],
          }
        end,
      }
    end

    ANSWER_ATTRIBUTES = %i[question_id question_type_id reply_id survey_id value].freeze

    def reply_attributes
      answers_attributes = survey.questions.reduce({}) do |attributes, question|
        attributes.merge!(question.id => ANSWER_ATTRIBUTES)
      end

      [:id, :survey_id, { answers_attributes: }]
    end
  end
end
