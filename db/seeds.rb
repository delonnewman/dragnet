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
      settings: { countable: { type: :boolean, text: 'Calculate Statistics', default: true },
                  decimal:   { type: :boolean, text: 'Allow decimal numbers', default: false } } },
    { name:     'Time',
      icon:     'fa-regular fa-clock',
      settings: { include_date: { type: :boolean, text: 'Include Date', default: true },
                  include_time: { type: :boolean, text: 'Include Time', default: true } } },
    { name: 'Yes or No',
      slug: 'boolean',
      icon: 'fa-regular fa-toggle-on' },
  ]
)

User.create!(
  login:    'admin',
  email:    'contact@delonnewman.name',
  name:     'Delon Newman',
  nickname: 'Delon',
  password: 'testing123'
).confirm

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
