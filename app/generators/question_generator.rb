# Generate a random question
class QuestionGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Question.new do |q|
      q.text          = Faker::Lorem.question
      q.survey        = attributes.fetch(:survey) { raise 'A survey attribute is required' }
      q.question_type = attributes.fetch(:question_type, QuestionType.generate)
      q.required      = Faker::Boolean.boolean(true_ratio: 0.3)

      case q.question_type.ident
      when :multiple_choice, :checkboxes
        (2..5).to_a.sample.times do
          q.question_options << QuestionOption[question: q].generate
        end
      end
    end
  end
end
