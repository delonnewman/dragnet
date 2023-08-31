# frozen_string_literal: true

module Dragnet
  class Workspace::RepliesByDate < Query
    query_doc 'The number of replies by date for an author or survey'

    alias space subject
    delegate :user, to: :space

    def call
      Reply
        .where(survey_id: user.survey_ids)
        .group("extract(year from updated_at) || '-' || extract(month from updated_at) || '-' || extract(day from updated_at)")
        .count
        .transform_keys { |d| Date.parse(d) }
    end
  end
end