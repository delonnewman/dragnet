# frozen_string_literal: true

class RepliesBySurveyAndDateQuery < Dragnet::Query
  query_text <<~SQL
    select
      r.survey_id,
      extract(year from r.updated_at) || '-' ||
      extract(month from r.updated_at) || '-' ||
      extract(day from r.updated_at) as reply_date,
      count(r.id) as reply_count
    from replies r
      inner join surveys s on s.id = r.survey_id
      inner join users u on u.id = s.author_id
    where s.author_id = ? and r.updated_at >= ?
    group by r.survey_id, reply_date
    order by reply_date desc
  SQL

  # @param [User] user
  #
  # @return [Hash{Date, Integer}]
  def call(user, after: Date.today - 180)
    hash_query(user.id, after)
      .group_by { |r| r[:survey_id] }
      .transform_values { |rs|
        rs.group_by { |r| r[:reply_date] }
          .transform_values! { |r| r.first[:reply_count] }
          .transform_keys! { |d| Date.parse(d) } }
  end
end
