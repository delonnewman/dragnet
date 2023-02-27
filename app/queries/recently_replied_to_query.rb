# frozen_string_literal: true

# TODO: add edit status, i.e. saved, unsaved changes, cannot save (error state)
class RecentlyRepliedToQuery < Dragnet::Query
  query_doc 'Your surveys that have most recently been replied to'
  query_text <<~SQL
    select
      s.id,
      s.name,
      s.slug,
      s.public,
      s.open,
      s.created_at,
      s.updated_at
    from users as u
        inner join surveys as s on u.id = s.author_id
        inner join replies as r on s.id = r.survey_id
      where r.submitted = true and u.id = ?
      group by s.id, s.name, s.slug, s.public, s.open, s.created_at, s.updated_at
      order by max(r.submitted_at)
    limit ?
  SQL

  def call(user, limit: 6)
    q Survey, user.id, limit
  end
end
