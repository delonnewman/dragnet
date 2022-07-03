QuestionType.create(
  [{ name: 'Text',   icon: 'fa-regular fa-keyboard',     options: { long_answer: :boolean } },
   { name: 'Choice', icon: 'fa-regular fa-square-check', options: { multiple_choice: :boolean, countable: :boolean } },
   { name: 'Number', icon: 'fa-regular fa-calculator',   options: { countable: :boolean } },
   { name: 'Time',   icon: 'fa-regular fa-clock',        options: { include_date: :boolean, include_time: :boolean } }]
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
