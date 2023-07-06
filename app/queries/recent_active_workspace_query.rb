# frozen_string_literal: true

class RecentActiveWorkspaceQuery < Dragnet::Query
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
                        s.edits_status,
                        s.copy_of_id,
                        copy.id        AS "copy_of_attributes[id]",
                        copy.name      AS "copy_of_attributes[name]",
                        copy.slug      AS "copy_of_attributes[slug]",
                        copy.author_id AS "copy_of_attributes[author_id]"
                   FROM users   AS u
             INNER JOIN surveys AS s    ON u.id         = s.author_id
        LEFT OUTER JOIN surveys AS copy ON s.copy_of_id = copy.id
                  WHERE s.created_at < ? AND u.id = ?
               ORDER BY s.created_at DESC)
    UNION
    /* recently replied to surveys */
              (SELECT s.id,
                      s.name,
                      s.slug,
                      s.public,
                      s.open,
                      s.created_at,
                      s.updated_at,
                      s.edits_status,
                      s.copy_of_id,
                      copy.id        AS "copy_of_attributes[id]",
                      copy.name      AS "copy_of_attributes[name]",
                      copy.slug      AS "copy_of_attributes[slug]",
                      copy.author_id AS "copy_of_attributes[author_id]"
                 FROM users   AS u
           INNER JOIN surveys AS s    ON u.id         = s.author_id
           INNER JOIN replies AS r    ON s.id         = r.survey_id
      LEFT OUTER JOIN surveys AS copy ON s.copy_of_id = copy.id
                WHERE r.submitted = true AND u.id = ?
             GROUP BY s.id, s.name, s.slug, s.public, s.open, s.created_at, s.updated_at, copy.id, copy.name, copy.slug
             ORDER BY max(r.submitted_at))
    LIMIT ?
  SQL

  # @param [User] user
  # @param [Time] last_created
  # @param [Integer] limit
  def call(user, last_created, limit: 6)
    q Survey, last_created, user.id, user.id, limit
  end
end
