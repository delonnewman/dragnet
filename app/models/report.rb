class Report
  attr_reader :question_ids, :name

  def initialize(attributes)
    @question_ids, @name = attributes.values_at(:question_ids, :name)
  end

  def questions
    @questions ||= Question.where(id: question_ids)
  end

  def answers
    @answers ||= Answer.where(question_id: question_ids)
  end

  def replies
    @replies ||= Reply.joins(:answers).where('answers.question_id in (?)', question_ids)
  end
end
