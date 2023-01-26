QuestionType.create(
  [
    { name:     'Text',
      icon:     'fa-regular fa-keyboard',
      settings: { long_answer: { type: :boolean, text: 'Long Answer' } } },
    { name:     'Choice',
      icon:     'fa-regular fa-square-check',
      settings: { multiple_answers: { type: :boolean, text: 'Multiple Answers' },
                  countable:        { type: :boolean, text: 'Calculate Statistics' } } },
    { name:     'Number',
      icon:     'fa-regular fa-calculator',
      settings: { countable: { type: :boolean, text: 'Calculate Statistics', default: true } } },
    { name:     'Time',
      icon:     'fa-regular fa-clock',
      settings: { include_date: { type: :boolean, text: 'Include Date', default: true },
                  include_time: { type: :boolean, text: 'Include Time', default: true } } }
  ]
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
      Survey[author: u].generate.tap do |s|
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
