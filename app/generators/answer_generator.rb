class AnswerGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey)    { raise 'A survey attribute is required' }
    r = attributes.fetch(:reply)     { raise 'A reply attribute is required'  }
    q = attributes.fetch(:question)  { raise 'A quesiton attribute is required' }

    v = case q.question_type.ident
        when :short_answer
          ShortAnswer.generate
        when :paragraph
          Paragraph.generate
        when :multiple_choice, :checkboxes
          QuestionOptionAnswer[q].generate
        end

    Answer.new(survey: s, reply: r, question: q) do |a|
      a.question_type = q.question_type
      a.value = v
    end
  end
end
