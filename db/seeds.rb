QuestionType.create(
  [
    { name:     'Text',
      icon:     'fa-regular fa-keyboard',
      answer_value_field: 'short_text_value',
      settings: { long_answer: { type: :boolean, text: 'Long Answer' } } },
    { name:     'Choice',
      icon:     'fa-regular fa-square-check',
      answer_value_field: 'question_option_id',
      settings: { multiple_answers: { type: :boolean, text: 'Multiple Answers' },
                  countable:        { type: :boolean, text: 'Calculate Statistics' } } },
    { name:     'Number',
      icon:     'fa-regular fa-calculator',
      answer_value_field: 'float_value',
      settings: { countable: { type: :boolean, text: 'Calculate Statistics', default: true } } },
    { name:     'Time',
      icon:     'fa-regular fa-clock',
      answer_value_field: 'integer_value',
      settings: { include_date: { type: :boolean, text: 'Include Date', default: true },
                  include_time: { type: :boolean, text: 'Include Time', default: true } } }
  ]
)

User.create!(login: 'admin', email: 'contact@delonnewman.name', name: 'Delon Newman', nickname: 'Delon', password: 'testing123').confirm

# Generate some sample data if in development
if Rails.env.development?
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
