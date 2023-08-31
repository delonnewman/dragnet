# Generate a random question
class Dragnet::QuestionGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Question.new do |q|
      q.text          = Faker::Movie.quote
      q.survey        = attributes.fetch(:survey) { raise 'A survey attribute is required' }
      q.question_type = attributes.fetch(:question_type, QuestionType.generate)
      q.required      = Faker::Boolean.boolean(true_ratio: 0.3)

      case q.question_type.ident
      when :choice
        count = (2..5).to_a.sample
        count.times do |i|
          q.question_options << QuestionOption[question: q, weight: i - (count / 2)].generate
        end
      when :text
        q.settings = { long_answer: true, countable: true } if Faker::Boolean.boolean(true_ratio: 0.3)
      end
    end
  end
end
