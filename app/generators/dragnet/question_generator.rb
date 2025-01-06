# Generate a random question
class Dragnet::QuestionGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Question.new do |q|
      q.survey          = attributes.fetch(:survey) { raise 'A survey attribute is required' }
      q.text            = Dragnet::QuestionText[other_questions: q.survey.questions.map(&:text).to_set].generate
      q.question_type   = attributes.fetch(:question_type, QuestionType.generate)
      q.type_class_name = attributes.fetch(:type_class_name, TypeClass.generate.name)
      q.required        = Faker::Boolean.boolean(true_ratio: 0.3)

      type = q.question_type.ident # rescue binding.pry
      case type
      when :choice
        count = (2..5).to_a.sample
        count.times do |i|
          q.question_options << QuestionOption[question: q, weight: i - (count / 2)].generate
        end
      end
    end
  end
end
