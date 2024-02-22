# frozen_string_literal: true

module Dragnet
  class User::ReplySubmissionPolicy < Policy
    alias user subject

    # @param [Survey, Reply] survey
    #
    # @return [Boolean]
    def can_submit_reply?(survey)
      survey = survey.survey if survey.is_a?(Reply)

      user == survey.author || survey.public? || survey.open?
    end
    alias can_create_reply? can_submit_reply?

    # @param  [Reply] reply
    #
    # @return [Boolean]
    def can_edit_reply?(reply)
      can_submit_reply?(reply) && !reply.submitted?
    end
    alias can_update_reply? can_submit_reply?

    # @param [Survey] survey
    # @param [Boolean] wants_preview
    #
    # @return [Boolean]
    def can_preview_survey?(survey, wants_preview:)
      wants_preview && can_submit_reply?(survey)
    end
  end
end
