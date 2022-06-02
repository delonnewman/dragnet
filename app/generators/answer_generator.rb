class AnswerGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey)    { raise 'A survey attribute is required' }
    r = attributes.fetch(:reply)     { raise 'A reply attribute is required'  }
    q = attributes.fetch(:question)  { raise 'A quesiton attribute is required' }

    v = case q.question_type
        when :short_answer
          Faker::Lorem.sentence
        when :paragraph
          Faker::Lorem.sentences
        when :multiple_choice
          q.question_options.to_a.sample((1..2).to_a.sample)
        when :checkboxes
          q.question_options.to_a.sample
        end

    Answer.new(survey: s, reply: r, question: q, value: v)
  end
end
