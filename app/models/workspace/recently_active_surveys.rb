# frozen_string_literal: true

class Workspace::RecentlyActiveSurveys < Dragnet::Query
  query_doc 'Your surveys that have recently been created or most recently been replied to'
  query_text <<~SQL
    /* created surveys */
                (SELECT s.id,
                        s.name,
                        s.slug,
                        s.public,
                        s.open,
                        s.created_at,
                        s.updated_at,
                        s.edits_status
                   FROM users   AS u
             INNER JOIN surveys AS s ON u.id = s.author_id
                  WHERE s.created_at < ? AND u.id = ?)
    UNION
    /* recently replied to surveys */
              (SELECT s.id,
                      s.name,
                      s.slug,
                      s.public,
                      s.open,
                      s.created_at,
                      s.updated_at,
                      s.edits_status
                 FROM users   AS u
           INNER JOIN surveys AS s    ON u.id         = s.author_id
           INNER JOIN replies AS r    ON s.id         = r.survey_id
                WHERE r.submitted = true AND u.id = ?
             GROUP BY s.id, s.name, s.slug, s.public, s.open, s.created_at, s.updated_at)
    ORDER BY created_at DESC
    LIMIT ?
  SQL

  alias space subject
  delegate :user, to: :space

  # @param [Time] last_created
  # @param [Integer] limit
  def call(last_created:, limit: 6)
    q Survey, last_created, user.id, user.id, limit
  end
end
