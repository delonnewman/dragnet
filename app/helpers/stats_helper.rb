module StatsHelper
  def auto_chart(data)
    if data.size < 5
      pie_chart(data)
    else
      column_chart(data)
    end
  end

  def data_table(data)
    tag.table(class: 'table') do
      tag.tbody do
        data.map do |key, value|
          tag.th(key) + tag.td(value)
        end.join(' ').html_safe
      end
    end
  end
end
