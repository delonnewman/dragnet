# frozen_string_literal: true

# Data projection for the reply submitter API
class Dragnet::ReplySubmissionPresenter < Dragnet::View::Presenter
  presents Reply, as: :reply

  def submission_data
    { survey: reply.survey.projection }
  end
end
