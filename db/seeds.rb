include Dragnet

TypeRegistration.create!(
  [
    { name: 'Text',
      type_class_name: 'Dragnet::Types::Text',
      meta: { fa_icon_class: 'fa-regular fa-keyboard' }
    },
    { name: 'Paragraphs',
      slug: 'long_text',
      type_class_name: 'Dragnet::Types::LongText',
      meta: { options: { countable: { type: :boolean, text: 'Calculate sentiment analysis score for text' } },
              fa_icon_class: 'fa-regular fa-keyboard' } },
    { name: 'Choice',
      type_class_name: 'Dragnet::Types::Choice',
      meta: { options: { multiple_answers: { type: :boolean, text: 'Allow multiple answers' },
                         countable:        { type: :boolean, text: 'Calculate statistics' } },
              fa_icon_class: 'fa-regular fa-square-check' } },
    { name: 'Whole Number',
      slug: 'integer',
      type_class_name: 'Dragnet::Types::Integer',
      meta: { options: { countable: { type: :boolean, text: 'Calculate statistics', default: true } },
              fa_icon_class: 'fa-regular fa-calculator' } },
    { name: 'Decimal',
      slug: 'decimal',
      type_class_name: 'Dragnet::Types::Decimal',
      meta: { options: { countable: { type: :boolean, text: 'Calculate statistics', default: true } },
              fa_icon_class: 'fa-regular fa-calculator' } },
    { name: 'Time',
      slug: 'time',
      type_class_name: 'Dragnet::Types::Time',
      meta: { fa_icon_class: 'fa-regular fa-clock' } },
    { name: 'Date',
      slug: 'date',
      type_class_name: 'Dragnet::Types::Date',
      meta: { fa_icon_class: 'fa-regular fa-clock' } },
    { name: 'Date & Time',
      slug: 'date_and_time',
      type_class_name: 'Dragnet::Types::DateAndTime',
      meta: { fa_icon_class: 'fa-regular fa-clock' } },
    { name: 'Yes or No',
      type_class_name: 'Dragnet::Types::Boolean',
      slug: 'boolean',
      meta: { fa_icon_class: 'fa-regular fa-toggle-on' } },
    { name: 'Email',
      type_class_name: 'Dragnet::Ext::Email',
      meta: { fa_icon_class: 'fa-regular fa-envelope' } },
    { name: 'Phone Number',
      slug: 'phone',
      type_class_name: 'Dragnet::Ext::Phone',
      meta: { fa_icon_class: 'fa-regular fa-envelope' } },
  ]
) if TypeRegistration.none?

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
      { text: 'Name',     type_class: Dragnet::Types::Text },
      { text: 'Email',    type_class: Dragnet::Ext::Email },
      { text: 'Address',  type_class: Dragnet::Types::Text },
      { text: 'Phone',    type_class: Dragnet::Ext::Phone },
      { text: 'Comments', type_class: Dragnet::Types::LongText, meta: { countable: true } },
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
