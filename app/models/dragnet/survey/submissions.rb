module Dragnet::Survey::Submissions
  extend ActiveSupport::Concern

  included do
    has_many :ahoy_visits, through: :replies
    has_many :events, through: :replies # Used by StatsReport

    with Dragnet::ReplySubmissionPolicy
    with Dragnet::Survey::SubmissionParameters
  end

  def reply_created?(visitor_token)
    !ahoy_visits.of_visitor(visitor_token).empty?
  end

  def reply_completed?(visitor_token)
    !ahoy_visits.of_visitor(visitor_token).where(replies: { submitted: true }).empty?
  end

  def existing_reply(visitor_token)
    ahoy_visits.of_visitor(visitor_token).first&.reply
  end
end
