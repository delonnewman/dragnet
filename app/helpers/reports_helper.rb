module ReportsHelper
  def answers_text(response, field, alt: '-', &block)
    items = response.items_for(field)
    return items.join(', ') unless items.empty?

    if block_given?
      block.call
      return
    end

    alt
  end

  def fmt_date(date)
    date.strftime('%Y-%m-%d')
  end

  def fmt_datetime(date)
    date.strftime('%Y-%m-%d %l:%M %p')
  end
end
