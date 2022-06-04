class ReplyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey) { raise 'A survey attribute is required' }

    Reply.new(survey: s) do |r|
      s.questions.each do |q|
        r.answers << Answer[survey: s, reply: r, question: q].generate
      end
    end
  end
end
