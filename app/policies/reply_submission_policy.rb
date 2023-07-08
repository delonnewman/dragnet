# frozen_string_literal: true

class ReplySubmissionPolicy < Dragnet::Policy
  alias user subject

  # @param [Survey, Reply] survey
  # @return [Boolean]
  def can_submit_reply?(survey)
    survey = survey.survey if survey.is_a?(Reply)

    user == survey.author || survey.public? || survey.open?
  end

  alias can_create_reply? can_submit_reply?
  alias can_edit_reply? can_submit_reply?
  alias can_update_reply? can_submit_reply?

  # @param [Survey] survey
  # @param [ActionController::Parameters] params
  # @return [Boolean]
  def can_preview_survey?(survey, params)
    can_submit_reply?(survey) && params[:preview].present?
  end

  # Return true if a reply to the survey has been created for the current visitor. Otherwise return false.
  #
  # @param [Survey] survey
  # @param [Ahoy::Visit] current_visit
  # @return [Boolean]
  def visitor_reply_created?(survey, current_visit)
    !survey.ahoy_visits.of_visitor(current_visit.visitor_token).empty?
  end

  # Return true if a reply to the survey has been created & submitted for the current visitor. Otherwise return false.
  #
  # @param [Survey] survey
  # @param [Ahoy::Visit] current_visit
  # @return [Boolean]
  def visitor_reply_submitted?(survey, current_visit)
    !survey.ahoy_visits.of_visitor(current_visit.visitor_token).where(replies: { submitted: true }).empty?
  end
end
