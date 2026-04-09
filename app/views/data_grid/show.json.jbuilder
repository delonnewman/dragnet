
json.id grid.survey.id
json.name grid.survey.name
json.page grid.page
json.items grid.items
json.query do
  json.sort_by grid.query.sort_by
  json.sort_direction grid.query.sort_direction
  json.sql grid.records.to_sql
end
json.records grid.records.map { |record|
  { created_at: fmt_datetime(record.created_at), user_id: record.user_id || '-' }.merge!(grid.questions.map { |q| [q.id, answers_text(record, q)] }.to_h)
}
