class Report
  attr_reader :question_ids, :name

  def initialize(attributes)
    @question_ids, @name = attributes.values_at(:question_ids, :name)
  end

  def questions
    @questions ||= Question.where(id: question_ids).select(:id, :text).to_a
  end

  def replies
    @replies ||= Reply.includes(:answers).joins(:answers).where('answers.question_id in (?)', question_ids)
  end
end
