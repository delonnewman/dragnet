class ReplyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey) { raise 'A survey attribute is required' }

    Reply.new(survey: s) do |r|
      r.created_at   = attributes.fetch(:created_at) { Faker::Date.between(from: 2.years.ago, to: Date.today) }
      r.updated_at   = attributes.fetch(:updated_at) { r.created_at }
      r.submitted    = Faker::Boolean.boolean(true_ratio: 0.8)
      r.submitted_at = r.created_at if r.submitted?

      s.questions.each do |q|
        next unless q.required? || Faker::Boolean.boolean(true_ratio: 0.3)

        r.answers << Answer[survey: s, reply: r, question: q, question_type_id: q.question_type_id].generate
      end
    end
  end
end
