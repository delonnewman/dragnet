include Dragnet

QuestionType.create(
  [
    { name:     'Text',
      icon:     'fa-regular fa-keyboard',
      type_class_name: 'Dragnet::Type::Text',
      meta: { long_answer: { type: :boolean, text: 'Long Answer' },
              countable:   { type: :boolean, text: 'Calculate sentiment analysis score for text' } } },
    { name:     'Choice',
      type_class_name: 'Dragnet::Type::Choice',
      icon:     'fa-regular fa-square-check',
      meta: { multiple_answers: { type: :boolean, text: 'Allow multiple answers' },
                  countable:        { type: :boolean, text: 'Calculate statistics' } } },
    { name:     'Number',
      type_class_name: 'Dragnet::Type::Number',
      icon:     'fa-regular fa-calculator',
      meta: { countable: { type: :boolean, text: 'Calculate statistics', default: true },
              decimal:   { type: :boolean, text: 'Allow decimal numbers', default: false } } },
    { name:     'Time',
      type_class_name: 'Dragnet::Type::Time',
      icon:     'fa-regular fa-clock',
      meta: { include_date: { type: :boolean, text: 'Include Date', default: true },
              include_time: { type: :boolean, text: 'Include Time', default: true } } },
    { name: 'Yes or No',
      type_class_name: 'Dragnet::Type::Boolean',
      slug: 'boolean',
      icon: 'fa-regular fa-toggle-on'
    },
  ]
)

user = User.create!(
  login:    'admin',
  email:    'contact@delonnewman.name',
  name:     'Delon Newman',
  nickname: 'Delon',
  password: 'testing123'
).tap(&:confirm)

Survey.create!(
  name:                 'Contact Information',
  author:               user,
  questions_attributes: [
    { text: 'Name',     question_type_ident: 'text' },
    { text: 'Email',    question_type_ident: 'text' },
    { text: 'Address',  question_type_ident: 'text', meta: { long_answer: true } },
    { text: 'Phone',    question_type_ident: 'text' },
    { text: 'Comments', question_type_ident: 'text', meta: { long_answer: true } },
  ]
)

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
    Array.new(5) do
      Survey[author: u].generate.tap do |s|
        s.save!
        print '.'
      end
    end
  end
  puts 'Done.'

  print 'Generating Replies...'
  surveys.each do |s|
    Dragnet::StatsUtils.time_series((Time.zone.today - 60)..(Time.zone.today)).each_pair do |created_at, count|
      next if Faker::Boolean.boolean(true_ratio: 0.6)

      count.times do
        Reply[survey: s, created_at: created_at].generate.tap do |r|
          r.save!
          visit = Ahoy::Visit.generate!
          Ahoy::Event[name: ReplyTracker::EVENT_TAGS[:view], visit: visit, survey_id: s.id, reply_id: r.id].generate!
          Ahoy::Event[name: ReplyTracker::EVENT_TAGS[:update], visit: visit, survey_id: s.id, reply_id: r.id].generate!
          Ahoy::Event[name: ReplyTracker::EVENT_TAGS[:complete], visit: visit, survey_id: s.id, reply_id: r.id].generate! if r.submitted?
          r.ahoy_visit = visit
          r.save!
          print '.'
        end
      end
    end
  end
  puts 'Done.'
end
