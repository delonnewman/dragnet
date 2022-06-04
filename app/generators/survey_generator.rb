# Generate random surveys
class SurveyGenerator < Dragnet::ActiveRecordGenerator
  DEFAULT_SETTINGS = { questions: { min: 4, max: 20 }.freeze }.freeze

  def call(other_attributes = DEFAULT_SETTINGS)
    Survey.new(name: Faker::Lorem.sentence, author: attributes.fetch(:author, User.generate)) do |s|
      min, max = other_attributes.fetch(:questions).values_at(:min, :max)
      (min..max).to_a.sample.times do
        s.questions << Question[survey: s].generate
      end
    end
  end
end
