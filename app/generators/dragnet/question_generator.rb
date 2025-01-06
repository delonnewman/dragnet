# Generate a random question
class Dragnet::QuestionGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Question.new do |q|
      q.survey        = attributes.fetch(:survey) { raise 'A survey attribute is required' }
      q.text          = Dragnet::QuestionText[other_questions: q.survey.questions.map(&:text).to_set].generate
      q.type_class    = attributes.fetch(:type_class, TypeClass.generate)
      q.required      = Faker::Boolean.boolean(true_ratio: 0.3)

      case q.type_class.symbol
      when :choice
        count = (2..5).to_a.sample
        count.times do |i|
          q.question_options << QuestionOption[question: q, weight: i - (count / 2)].generate
        end
      end
    end
  end
end
