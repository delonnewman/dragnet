module ReportsHelper
  def answers_text(reply, question, alt: '-', &block)
    answers = reply.answers_to(question)
    return answers.join(', ') unless answers.empty?

    if block_given?
      block.call
      return
    end

    alt
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end
end
