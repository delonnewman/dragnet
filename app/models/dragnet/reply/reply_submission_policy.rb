module Dragnet
  class Reply::ReplySubmissionPolicy < Survey::ReplySubmissionPolicy
    attr_reader :reply

    def initialize(reply)
      super(reply.survey)
      @reply = reply
    end

    # @param  [Reply] reply
    #
    # @return [Boolean]
    def can_edit_reply?(user)
      user_can_submit_reply?(user) && !reply.submitted?
    end
    alias can_update_reply? user_can_submit_reply?
  end
end
