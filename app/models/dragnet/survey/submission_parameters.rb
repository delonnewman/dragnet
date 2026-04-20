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
        answers_attributes: questions.map { |question|
          {
            question_id: question.id,
            type: question.type.symbol,
            reply_id: reply.id,
            survey_id: survey.id,
            value: data[question.form_name],
          }
        },
      }
    end

    ANSWER_ATTRIBUTES = %i[question_id question_type_id reply_id survey_id type value].freeze

    def reply_attributes
      answers_attributes = survey.questions.reduce({}) do |attributes, question|
        attributes.merge!(question.id => ANSWER_ATTRIBUTES)
      end

      [{ answers_attributes: }]
    end
  end
end
