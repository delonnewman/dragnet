# frozen_string_literal: true

class RepliesByDateQuery < Dragnet::Query
  query_doc 'The number of replies by date for an author or survey'

  def call(survey_ids)
    Reply
      .where(survey_id: survey_ids)
      .group("extract(year from updated_at) || '-' || extract(month from updated_at) || '-' || extract(day from updated_at)")
      .count
      .transform_keys { |d| Date.parse(d) }
  end
end
