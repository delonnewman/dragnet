# frozen_string_literal: true

class Report
  include Dragnet::Memoizable

  attr_reader :question_ids, :name

  def initialize(attributes)
    @question_ids, @name = attributes.values_at(:question_ids, :name)
  end

  def questions
    Question.where(id: question_ids).select(:id, :text).load
  end
  memoize :questions

  def answers
    Answer.includes(question: [:question_type]).where(question_id: question_ids)
  end

  def records
    Reply
      .includes(:answers)
      .joins(:answers)
      .where('replies.submitted and answers.question_id in (?)', question_ids)
      .order('replies.created_at DESC')
  end
end
