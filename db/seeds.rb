include Dragnet

QuestionType.create!(
  [
    { name: 'Text',
      icon: 'fa-regular fa-keyboard',
      type_class_name: 'Dragnet::Types::Text' },
    { name: 'Paragraphs',
      slug: 'long_text',
      icon: 'fa-regular fa-keyboard',
      type_class_name: 'Dragnet::Types::LongText',
      meta: { countable:   { type: :boolean, text: 'Calculate sentiment analysis score for text' } } },
    { name: 'Choice',
      type_class_name: 'Dragnet::Types::Choice',
      icon: 'fa-regular fa-square-check',
      meta: { multiple_answers: { type: :boolean, text: 'Allow multiple answers' },
              countable:        { type: :boolean, text: 'Calculate statistics' } } },
    { name: 'Whole Number',
      slug: 'integer',
      type_class_name: 'Dragnet::Types::Integer',
      icon: 'fa-regular fa-calculator',
      meta: { countable: { type: :boolean, text: 'Calculate statistics', default: true } } },
    { name: 'Decimal',
      slug: 'decimal',
      type_class_name: 'Dragnet::Types::Decimal',
      icon: 'fa-regular fa-calculator',
      meta: { countable: { type: :boolean, text: 'Calculate statistics', default: true } } },
    { name: 'Time',
      slug: 'time',
      type_class_name: 'Dragnet::Types::Time',
      icon: 'fa-regular fa-clock' },
    { name: 'Date',
      slug: 'date',
      type_class_name: 'Dragnet::Types::Date',
      icon: 'fa-regular fa-clock' },
    { name: 'Date & Time',
      slug: 'date_and_time',
      type_class_name: 'Dragnet::Types::DateAndTime',
      icon: 'fa-regular fa-clock' },
    { name: 'Yes or No',
      type_class_name: 'Dragnet::Types::Boolean',
      slug: 'boolean',
      icon: 'fa-regular fa-toggle-on' },
    { name: 'Email',
      icon: 'fa-regular fa-envelope',
      type_class_name: 'Dragnet::Ext::Email' },
    { name: 'Phone Number',
      slug: 'phone',
      icon: 'fa-regular fa-envelope',
      type_class_name: 'Dragnet::Ext::Phone' },
    { name: 'Address',
      icon: 'fa-regular fa-envelope',
      type_class_name: 'Dragnet::Ext::Address' },
  ]
) if QuestionType.none?

unless Rails.env.test?
  user = User.find_by(login: 'admin') || User.new(
    login:    'admin',
    email:    'contact@delonnewman.name',
    name:     'Delon Newman',
    nickname: 'Delon',
    password: 'testing123'
  ).tap { |user| user.skip_confirmation!; user.save! }

  Survey.create!(
    name: 'Contact Information',
    author: user,
    public: true,
    questions_attributes: [
      { text: 'Name',     question_type_ident: 'text' },
      { text: 'Email',    question_type_ident: 'email' },
      { text: 'Address',  question_type_ident: 'address' },
      { text: 'Phone',    question_type_ident: 'phone' },
      { text: 'Comments', question_type_ident: 'long_text', meta: { countable: true } },
    ]
  ) unless Survey.exists?(name: 'Contact Information')
end

# Generate some sample data if in development
if Rails.env.development? && User.count == 1
  puts 'Generating some data that should aid development 🦫🚧 ...'

  print 'Generating Users...'
  5.times do
    User[password: 'testing123'].generate.tap do |u|
      print u.save ? '.' : 'x'
    end
  end
  puts 'Done.'

  print 'Generating Surveys...'
  surveys = User.all.flat_map do |u|
    Array.new(5) do
      Survey[author: u].generate.tap do |s|
        print s.save ? '.' : 'x'
      end
    end
  end
  puts 'Done.'

  print 'Generating Replies...'
  surveys.each do |survey|
    survey_id = survey.id
    Dragnet::StatsUtils.time_series((Time.zone.today - 60)..(Time.zone.today)).each_pair do |created_at, count|
      next if Faker::Boolean.boolean(true_ratio: 0.6)

      count.times do
        Reply[survey:, created_at:].generate.tap do |reply|
          reply.save!
          reply_id = reply.id
          visit = Ahoy::Visit.generate!
          Ahoy::Event[name: ReplyTracker.event_name(:view), visit:, survey_id:, reply_id:].generate!
          Ahoy::Event[name: ReplyTracker.event_name(:update), visit:, survey_id:, reply_id:].generate!
          if reply.submitted?
            Ahoy::Event[name: ReplyTracker.event_name(:complete), visit:, survey_id:, reply_id:].generate!
          end
          reply.ahoy_visit = visit
          print reply.save ? '.' : 'x'
        end
      end
    end
  end
  puts 'Done.'
end
