module ReportsHelper
  def answers_text(reply, question, alt: '-')
    AnswersDisplay.init(question.question_type, self).to_html(reply, question, alt: alt)
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end

  def fmt_datetime(date)
    date.strftime('%Y-%m-%d %l:%M %p')
  end
end
