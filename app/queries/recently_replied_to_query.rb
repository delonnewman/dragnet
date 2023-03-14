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
      s.updated_at,
      s.edits_status,
      copy.id as "copy_of_attributes[id]",
      copy.name as "copy_of_attributes[name]",
      copy.slug as "copy_of_attributes[slug]",
      copy.author_id as "copy_of_attributes[author_id]"
    from users as u
        inner join surveys as s on u.id = s.author_id
        inner join replies as r on s.id = r.survey_id
        left outer join surveys as copy on s.copy_of_id = copy.id
      where r.submitted = true and u.id = ?
      group by s.id, s.name, s.slug, s.public, s.open, s.created_at, s.updated_at, copy.id, copy.name, copy.slug
      order by max(r.submitted_at)
    limit ?
  SQL

  def call(user, limit: 6)
    q Survey, user.id, limit
  end
end
