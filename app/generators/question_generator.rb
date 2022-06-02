# Generate a random question
class QuestionGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Question.new do |q|
      q.text          = Faker::Lorem.sentence
      q.survey        = attributes.fetch(:survey) { raise "A survey attribute is required" }
      q.question_type = attributes.fetch(:question_type, QuestionType.generate)
    end
  end
end
