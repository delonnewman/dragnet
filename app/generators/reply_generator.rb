class ReplyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey) { raise 'A survey attribute is required' }

    Reply.new(survey: s) do |r|
      s.questions.each do |q|
        next unless q.required? || Faker::Boolean.boolean(true_ratio: 0.2)

        r.answers << Answer[survey: s, reply: r, question: q, question_type_id: q.question_type_id].generate
      end
    end
  end
end
