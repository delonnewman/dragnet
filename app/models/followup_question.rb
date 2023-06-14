# frozen_string_literal: true

# TODO: Remove followup questions
class FollowupQuestion < Question
  belongs_to :question
  belongs_to :question_option
end
