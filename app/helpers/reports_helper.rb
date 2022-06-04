module ReportsHelper
  def answers_text(reply, question)
    reply.answers_to(question).join(', ')
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end
end
