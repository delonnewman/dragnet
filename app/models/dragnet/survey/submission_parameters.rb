# frozen_string_literal: true

module Dragnet
  class Survey::SubmissionParameters < Composed
    alias survey subject

    def form_attributes
      survey.questions.map(&:form_name)
    end

    def form_data(reply, params)
      data = params.to_h
      questions = Question.where(form_name: data.keys)

      {
        answers_attributes: questions.map do |question|
          {
            question_id: question.id,
            reply_id: reply.id,
            survey_id: survey.id,
            value: data[question.form_name],
          }
        end,
      }
    end
  end
end
