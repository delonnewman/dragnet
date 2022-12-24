# frozen_string_literal: true

# Data projection for the reply submitter API
class ReplySubmissionPresenter < Dragnet::View::Presenter
  presents Reply, as: :reply

  def submission_data
    { survey:         reply.survey.projection,
      question_types: question_types }
  end

  def question_types
    QuestionTypesPresenter.new(QuestionType.all).question_types_mapping
  end
end
