module ReportsHelper
  def answers_text(reply, question, alt: '-')
    question.renderer(DataGridDisplayPerspective.new(self)).render(reply.answers_to(question), alt: alt)
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end

  def fmt_datetime(date)
    date.strftime('%Y-%m-%d %l:%M %p')
  end
end
