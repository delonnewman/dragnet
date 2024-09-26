module Dragnet
  class ReplySubmissionPolicy < Policy
    attr_reader :reply, :survey

    def initialize(subject)
      super(subject)
      if subject.is_a?(Reply)
        @reply = subject
        @survey = subject.survey
      else
        @survey = subject
      end
    end

    # @param [User] user
    #
    # @return [Boolean]
    def can_submit_reply?(user)
      user == survey.author || survey.public? || survey.open?
    end
    alias can_preview? can_submit_reply?

    # @param  [Reply] reply
    #
    # @return [Boolean]
    def can_edit_reply?(user)
      can_submit_reply?(user) && !reply.submitted?
    end
    alias can_update_reply? can_edit_reply?
    alias can_complete_reply? can_edit_reply?
  end
end
