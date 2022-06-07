class Report
  attr_reader :question_ids, :name

  def initialize(attributes)
    @question_ids, @name = attributes.values_at(:question_ids, :name)
  end

  def questions
    @questions ||= Question.where(id: question_ids).select(:id, :text).to_a
  end

  def replies
    @replies ||= Reply.includes(:answers).joins(:answers).where('answers.question_id in (?)', question_ids).order('replies.created_at DESC')
  end

  def answers
    @answers ||= Answer.includes(question: [:question_type]).where(question_id: question_ids)
  end
end
