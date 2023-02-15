# frozen_string_literal: true

class ReplySubmissionPolicy < Dragnet::Policy
  alias user subject

  def can_submit_reply?(survey)
    survey = survey.survey if survey.is_a?(Reply)

    user == survey.author || survey.public? || survey.open?
  end

  alias can_create_reply? can_submit_reply?
  alias can_edit_reply? can_submit_reply?
  alias can_update_reply? can_submit_reply?
end
