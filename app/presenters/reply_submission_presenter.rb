# frozen_string_literal: true

# Data projection for the reply submitter API
class ReplySubmissionPresenter < Dragnet::View::Presenter
  presents Reply, as: :reply

  def submission_data
    reply.survey.projection
  end
end
