class FollowupQuestion < Question
  belongs_to :question
  belongs_to :question_option
end
