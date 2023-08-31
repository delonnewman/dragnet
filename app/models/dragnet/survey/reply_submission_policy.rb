# frozen_string_literal: true

module Dragnet
  class Survey::ReplySubmissionPolicy < Policy
    alias survey subject

    # Return true if a reply to the survey has been created for the current visitor. Otherwise return false.
    #
    # @param [Ahoy::Visit] current_visit
    # @return [Boolean]
    def visitor_reply_created?(current_visit)
      !survey.ahoy_visits.of_visitor(current_visit.visitor_token).empty?
    end

    # Return true if a reply to the survey has been created & submitted for the current visitor. Otherwise return false.
    #
    # @param [Ahoy::Visit] current_visit
    # @return [Boolean]
    def visitor_reply_submitted?(current_visit)
      !survey.ahoy_visits.of_visitor(current_visit.visitor_token).where(replies: { submitted: true }).empty?
    end
  end
end