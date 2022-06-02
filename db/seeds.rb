QuestionType.create(
  [{ name: 'Short Answer' },
   { name: 'Paragraph' },
   { name: 'Multiple Choice' },
   { name: 'Checkboxes' }]
)

# Generate some sample data unless in production
unless Rails.env.production?
  users   = 5.times.map { User.generate.tap(&:save!) }
  surveys = users.flat_map { |u| 5.times.map { Survey[user: u].generate.tap(&:save!) } }

  surveys.each do |s|
    (50..100).to_a.sample.times do
      Reply[survey: s].generate
    end
  end
end
