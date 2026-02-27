
json.id grid.survey.id
json.name grid.survey.name
json.page grid.page
json.items grid.items
json.records grid.records.map { |record| grid.questions.map { |q| [q.id, answers_text(record, q)] }.to_h }
