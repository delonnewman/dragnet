# frozen_string_literal: true

module Dragnet
  class Survey::ReplySubmissionPolicy < Policy
    alias survey subject

    # Return true if a reply to the survey has been created for the current visitor. Otherwise return false.
    #
    # @param visitor_token
    # @return [Boolean]
    def visitor_reply_created?(visitor_token)
      !survey.ahoy_visits.of_visitor(visitor_token).empty?
    end

    # Return true if a reply to the survey has been created & submitted for the current visitor. Otherwise return false.
    #
    # @param visitor_token
    # @return [Boolean]
    def visitor_reply_submitted?(visitor_token)
      !survey.ahoy_visits.of_visitor(visitor_token).where(replies: { submitted: true }).empty?
    end

    # @param [User] user
    #
    # @return [Boolean]
    def can_submit_reply?(user)
      user == survey.author || survey.public? || survey.open?
    end
  end
end
