class Dragnet::ReplyFormPresenter < Dragnet::View::Presenter
  include Rails.application.routes.url_helpers

  presents Reply, as: :reply

  def survey
    reply.survey
  end
  
  def submission_action
    submit_reply_path(reply)
  end

  def submission_method
    :post
  end

  def show_description?
    survey.description.present?
  end

  def non_post_method?
    submission_method != :post
  end
end
