QuestionType.create(
  [{ name: 'Short Answer' },
   { name: 'Paragraph' },
   { name: 'Multiple Choice', countable: true },
   { name: 'Checkboxes', countable: true }]
)

# Generate some sample data unless in production
unless Rails.env.production?
  puts 'Generating some data that should aid development 🦫🚧 ...'

  print 'Generating Users...'
  users = 5.times.map do
    User.generate.tap do |u|
      u.save!
      print '.'
    end
  end
  puts 'Done.'

  print 'Generating Surveys...'
  surveys = users.flat_map do |u|
    5.times.map do
      Survey[user: u].generate.tap do |s|
        s.save!
        print '.'
      end
    end
  end
  puts 'Done.'

  print 'Generating Replies...'
  surveys.each do |s|
    (50..100).to_a.sample.times do
      Reply[survey: s].generate.tap do |r|
        r.save!
        print '.'
      end
    end
  end
  puts 'Done.'
end
