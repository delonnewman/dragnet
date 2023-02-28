QuestionType.create(
  [
    { name:     'Text',
      icon:     'fa-regular fa-keyboard',
      type_class_name: 'Dragnet::QuestionTypes::TextType',
      settings: { long_answer: { type: :boolean, text: 'Long Answer' } } },
    { name:     'Choice',
      icon:     'fa-regular fa-square-check',
      type_class_name: 'Dragnet::QuestionTypes::ChoiceType',
      settings: { multiple_answers: { type: :boolean, text: 'Multiple Answers' },
                  countable:        { type: :boolean, text: 'Calculate Statistics' } } },
    { name:     'Number',
      icon:     'fa-regular fa-calculator',
      type_class_name: 'Dragnet::QuestionTypes::NumberType',
      settings: { countable: { type: :boolean, text: 'Calculate Statistics', default: true } } },
    { name:     'Time',
      icon:     'fa-regular fa-clock',
      type_class_name: 'Dragnet::QuestionTypes::TimeType',
      settings: { include_date: { type: :boolean, text: 'Include Date', default: true },
                  include_time: { type: :boolean, text: 'Include Time', default: true } } }
  ]
)

User.create!(login: 'admin', email: 'contact@delonnewman.name', name: 'Delon Newman', nickname: 'Delon', password: 'testing123').confirm

# Generate some sample data unless in production
unless Rails.env.production?
  puts 'Generating some data that should aid development 🦫🚧 ...'

  print 'Generating Users...'
  5.times do
    User[password: 'testing123'].generate.tap do |u|
      u.save!
      print '.'
    end
  end
  puts 'Done.'

  print 'Generating Surveys...'
  surveys = User.all.flat_map do |u|
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
