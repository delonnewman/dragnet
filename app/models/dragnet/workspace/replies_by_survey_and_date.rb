# frozen_string_literal: true

module Dragnet
  class Workspace::RepliesBySurveyAndDate < Query
    query_text <<~SQL
      SELECT
        r.survey_id,
        EXTRACT(YEAR FROM r.updated_at) || '-' ||
        EXTRACT(MONTH FROM r.updated_at) || '-' ||
        EXTRACT(DAY FROM r.updated_at) AS reply_date,
        COUNT(r.id) AS reply_count
      FROM replies r
        INNER JOIN surveys s ON s.id = r.survey_id
        INNER JOIN users u ON u.id = s.author_id
      WHERE s.author_id = ? AND r.updated_at >= ? AND s.retracted = false
      GROUP BY r.survey_id, reply_date
      ORDER BY reply_date DESC
    SQL

    alias space subject
    delegate :user, to: :space

    # @param [Date] after
    #
    # @return [Hash{Date, Integer}]
    def call(after: Date.today - 180)
      hash_query(user.id, after)
        .group_by { |r| r[:survey_id] }
        .transform_values { |rs|
          rs.group_by { |r| r[:reply_date] }
            .transform_values! { |r| r.first[:reply_count] }
            .transform_keys! { |d| Date.parse(d) } }
    end
  end
end