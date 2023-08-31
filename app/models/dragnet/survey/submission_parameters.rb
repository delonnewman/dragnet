# frozen_string_literal: true

class Dragnet::Survey::SubmissionParameters < Dragnet::Composed
  alias survey subject

  def call
    { answers_attributes: answers_attributes }
  end

  private

  def answers_attributes
    survey.questions.each_with_object({}) do |q, h|
      h[q.id] = %i[answer_id reply_id survey_id question_type_id value]
    end
  end
end
