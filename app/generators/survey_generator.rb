# Generate random surveys
class SurveyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    name = Faker::Lorem.sentence
    
    Survey.new(name: name, author: attributes.fetch(:author, User.generate))
  end
end
