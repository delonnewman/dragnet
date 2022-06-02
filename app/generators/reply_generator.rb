class ReplyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey) { raise 'A survey attribute is required' }

    Reply.new(survey: s) do |r|
      r.answers_attributes = s.questions.map { |q| Answer[survey: s, reply: r, question: q].generate.attributes }
    end
  end
end
